package jp.coremind.core
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.event.ElementInfo;
    import jp.coremind.module.ModuleList;
    import jp.coremind.module.ScrollModule;
    import jp.coremind.utility.Delay;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.ContainerWrapper;
    import jp.coremind.view.implement.starling.component.ListContainer;
    import jp.coremind.view.interaction.Drag;
    
    import starling.core.Starling;
    
    public class DragAndDropController extends Controller
    {
        private static var _CONFIGURE_LIST:Vector.<DragAndDropConfigure> = new <DragAndDropConfigure>[];
        public static function addConfigure(configure:DragAndDropConfigure):int
        {
            return _CONFIGURE_LIST.push(configure) - 1;
        }
        
        private var
            _initialHitArea:Rectangle,
            _latestHitArea:Rectangle,
            _currentConfigureId:int;
        
        private function get configure():DragAndDropConfigure
        {
            return _CONFIGURE_LIST[_currentConfigureId];
        }
        
        public function beginDrag(info:ElementInfo, confId:int):void
        {
            var dragElement:IElement = info.path.fetchElement(starlingRoot);
            if (dragElement && 0 <= confId && confId < _CONFIGURE_LIST.length)
            {
                _currentConfigureId = confId;
                
                if (dragElement is ContainerWrapper)
                    Log.warning("ContainerWrapper(SuperClass) not Supported Drag.");
                else
                if (Controller.exec(configure.controllerClass, "dragFiltering", [info]))
                {
                    var before:Point = Application.pointer.clone();
                    new Delay().start(configure.dragDelay, function():void
                    {
                        var executeRange:Number = 2 * Starling.contentScaleFactor;
                        var size:Point = Application.pointer.subtract(before);
                        
                        if (Math.abs(size.x) < executeRange || Math.abs(size.y) < executeRange)
                            _beginDrag(dragElement);
                    });
                }
            }
        }
        
        private static const _TMP_POINT:Point    = new Point();
        private static const _TMP_RECT:Rectangle = new Rectangle();
        private function _beginDrag(from:IElement):void
        {
            //ドラッグしたオブジェクトの座標, サイズ情報を_latestHitAreaオブジェクトに与える為に一度ヒットテストを行っておく.
            _hitTestByElement(from, true);
            _initialHitArea = _latestHitArea.clone();
            
            //closure
            var onDrag:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                clonedElement.x = globalInitialPosition.x + x.totalDelta;
                clonedElement.y = globalInitialPosition.y + y.totalDelta;
                Controller.exec(klass, "onDrag", [x, y]);
                
                //同期処理中の場合は以降の処理をしない
                if (Application.sync.isRunning())
                    return;
                
                if (_latestHitArea.isEmpty())
                {
                    //ロールオーバーチェック(ヒットテストに成功すると_latestHitAreaの内容が書き換わる(emptyではなくなる))
                    var  hitTestResult:ElementInfo = _eachHitTest();
                    if (!hitTestResult) return;
                    
                    //ロールオーバー処理
                    rolloverDelay.start(configure.rolloverDelay, function():void
                    {
                        if (_latestHitArea.containsPoint(Application.pointer))
                        {
                            if (configure.invisibleWhenRollover)
                                clonedElement.visible = false;
                            
                            params[1] = hitTestResult;
                            params[3] = _initialHitArea.containsPoint(Application.pointer);
                            Controller.exec(klass, "onRollover", params);
                        }
                    });
                    return;
                }
                
                //ロールアウトチェック(最後にヒットテストに成功したオブジェクトとの当たり判定がある場合)
                if (_latestHitArea.containsPoint(Application.pointer))
                {
                    if (configure.absorbWhenRollover)
                    {
                        clonedElement.x = _latestHitArea.x;
                        clonedElement.y = _latestHitArea.y;
                    }
                    return;
                }
                //ここを抜けたらロールアウト処理
                
                //ロールオーバーの遅延実行待ちならキャンセル
                if (rolloverDelay.running)
                    rolloverDelay.stop();
                
                //初回ロールアウト処理
                if (params[1] !== null)
                {
                    params[3] = false;
                    Controller.exec(klass, "onRollout", params);
                    params[1] = null;
                    
                    if (configure.invisibleWhenRollover)
                        clonedElement.visible = true;
                }
                
                //ヒットテスト初期化
                _latestHitArea.setEmpty();
            };
            
            var onDrop:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                if (Application.sync.isRunning())
                    Application.sync.pushQue(function():void { onDrop(x, y); });
                else
                {
                    Controller.exec(klass, "onDrop", params);
                    clonedElement.destroy(true);
                    
                    if (mod) mod.ignorePointerDevice(false);
                }
            };
            
            //ドラッグ対象の親がScrollModuleを保持している場合停止させる.
            var parent:IElement  = from.parentDisplay as IElement;
            if (parent)
            {
                var mod:ScrollModule = parent.elementInfo.modules.isUndefined(ScrollModule) ?
                    null:
                    parent.elementInfo.modules.getModule(ScrollModule) as ScrollModule;
                
                if (mod) mod.ignorePointerDevice(true);
            }
            
            var clonedElement:IElement = from.clone();
            var globalInitialPosition:Point = from.toGlobalPoint(new Point());
            clonedElement.x = globalInitialPosition.x;
            clonedElement.y = globalInitialPosition.y;
            
            
            //closure variable
            var klass:Class         = configure.controllerClass;
            var params:Array        = [from.elementInfo, from.elementInfo, clonedElement.elementInfo, false];
            var rolloverDelay:Delay = new Delay();
            
            
            var layerRoot:ICalSprite   = Starling.current.stage.getChildAt(0) as ICalSprite;
            var systemLayer:ICalSprite = layerRoot.getDisplayByName(Layer.SYSTEM) as ICalSprite;
            systemLayer.addDisplay(clonedElement);
            
            from.toLocalPoint(Application.pointer, _TMP_POINT);
            _TMP_RECT.setTo(_TMP_POINT.x, _TMP_POINT.y, from.elementWidth, from.elementHeight);
            
            var dragger:Drag = new Drag(0);
            dragger.initialize(_TMP_RECT, new Rectangle(0, 55, 320, 568 - 55), onDrag, onDrop);
            dragger.beginPointerDeviceListening();
            
            Controller.exec(klass, "onDragBegin", params);
        }
        
        private function _eachHitTest():ElementInfo
        {
            var list:Array = configure.dropAreaList;
            
            for (var i:int = 0; i < list.length; i++)
            {
                var result:ElementInfo = _hitTest(list[i]);
                if (result) return result;
            }
            
            return null;
        }
        
        private function _hitTest(dropArea:ElementPathParser):ElementInfo
        {
            var e:IElement = dropArea.fetchElement(starlingRoot);
            
            if (e)
            {
                if (e is ListContainer)   return _hitTestByListContainer(dropArea);
                if (_hitTestByElement(e)) return e.elementInfo;
            }
            
            return null;
        }
        
        private function _hitTestByListContainer(dropArea:ElementPathParser):ElementInfo
        {
            var result:ElementInfo = null;
            
            each(function(value:*, model:ModuleList, info:ElementInfo):Boolean
            {
                var e:IElement = info.path.fetchElement(starlingRoot);
                
                if (e && _hitTestByElement(e))
                    result = info;
                
                return Boolean(result);
            }, dropArea.layerId, dropArea.viewId, dropArea.elementId);
            
            return result;
        }
        
        private static const _ZERO:Point = new Point();
        private function _hitTestByElement(e:IElement, ignoreFiltering:Boolean = false):Boolean
        {
            //外部で実装されたドロップ対象判定を考慮し、その判定に入らない場合ヒットテストを行う前に失敗させる.
            if (!ignoreFiltering && !Controller.exec(configure.controllerClass, "dropFiltering", [e.elementInfo]))
                return false;
            
            var c:IContainer = e as IContainer;
            
            e.toGlobalPoint(_ZERO, _TMP_POINT);
            c ? _TMP_RECT.setTo(_TMP_POINT.x, _TMP_POINT.y, c.maxWidth, c.maxHeight):
                _TMP_RECT.setTo(_TMP_POINT.x, _TMP_POINT.y, e.elementWidth, e.elementHeight);
            if (_TMP_RECT.containsPoint(Application.pointer))
            {
                _latestHitArea = _TMP_RECT.clone();
                return true;
            }
            else return false;
        }
    }
}