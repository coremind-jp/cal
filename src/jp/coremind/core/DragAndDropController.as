package jp.coremind.core
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.event.ElementInfo;
    import jp.coremind.module.ModuleList;
    import jp.coremind.module.ScrollModule;
    import jp.coremind.module.StatusGroup;
    import jp.coremind.module.StatusModule;
    import jp.coremind.utility.Delay;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.utility.data.Status;
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
            _running:Boolean,
            _dragDelay:Delay,
            _initialHitArea:Rectangle,
            _latestHitArea:Rectangle,
            _latestPointer:Point,
            _currentConfigureId:int;
        
        public function DragAndDropController()
        {
            _latestPointer = new Point();
            _dragDelay = new Delay();
        }
            
        private function get configure():DragAndDropConfigure
        {
            return _CONFIGURE_LIST[_currentConfigureId];
        }
        
        public function beginDrag(info:ElementInfo, confId:int):void
        {
            //ドラッグ結果によってリアルタイムに表示オブジェクトを消したり戻したりた際に
            //ドラッグ中のオブジェクトが再びこのメソッドを呼ぶ場合があるので稼動中の場合はキャンセルさせる.
            if (_running) return;
            
            var  dragElement:IElement = info.path.fetchElement(starlingRoot);
            if (!dragElement || confId < 0 && _CONFIGURE_LIST.length <= confId)
                return;
            
            if (dragElement is ContainerWrapper)
            {
                Log.warning("ContainerWrapper(SuperClass) not Supported Drag.");
                return;
            }
            
            _currentConfigureId = confId;
            if (Controller.exec(configure.controllerClass, "dragFiltering", [info]))
            {
                //呼び出された時点でのポインター位置を記憶
                var before:Point = Application.pointer.clone();
                
                _dragDelay.exec(function():void
                {
                    //遅延実行時、ポインターデバイスの状態が変わっていないか
                    var  status:StatusModule = info.modules.getModule(StatusModule) as StatusModule;
                    if (!status.equalGroup(StatusGroup.PRESS) || !status.equal(Status.DOWN))
                        return;
                    
                    _latestPointer.setTo(Application.pointerX, Application.pointerY);
                    //遅延実行時、ポインターデバイスの移動量が閾値内か
                    var executeRange:Number = Starling.contentScaleFactor;
                    var size:Point = _latestPointer.subtract(before);
                    if (Math.abs(size.x) < executeRange && Math.abs(size.y) < executeRange)
                        _beginDrag(dragElement);
                    
                //ドラッグオブジェクトの親がScrollModuleをもっている場合、この処理開始時にそのモジュールを停止させるが
                //delayが0で完全同期的に実行されるとをロックした後にスクロール開始判定が入ってしまい、
                //初回のドラッグ時にスクロールも発生してしまう。これを回避するため例え0でも1ms加算させてドラッグ開始を遅らせる.
                }, configure.dragDelay + 1);
            }
        }
        
        private static const _TMP_POINT:Point    = new Point();
        private static const _TMP_RECT:Rectangle = new Rectangle();
        private function _beginDrag(from:IElement):void
        {
            _running = true;
            
            //ドラッグ対象の親がScrollModuleを保持している場合停止させる.
            var parent:IElement  = from.parentDisplay as IElement;
            var mod:ScrollModule;
            if (parent)
            {
                parent.elementInfo.path.fetchView(starlingRoot).allocateElementCache();
                
                mod = parent.elementInfo.modules.isUndefined(ScrollModule) ?
                    null:
                    parent.elementInfo.modules.getModule(ScrollModule) as ScrollModule;
                
                if (mod) mod.ignorePointerDevice(true);
            }
            
            //duplicate drag object
            var clonedElement:IElement = from.clone();
            var globalInitialPosition:Point = from.toGlobalPoint(new Point());
            clonedElement.x = globalInitialPosition.x;
            clonedElement.y = globalInitialPosition.y;
            clonedElement.alpha = .5;
            
            var layerRoot:ICalSprite   = Starling.current.stage.getChildAt(0) as ICalSprite;
            var systemLayer:ICalSprite = layerRoot.getDisplayByName(Layer.SYSTEM) as ICalSprite;
            systemLayer.addDisplay(clonedElement);
            
            
            //closure variable
            var klass:Class          = configure.controllerClass;
            var params:Array         = [from.elementInfo, from.elementInfo, clonedElement.elementInfo, true];
            var rolloverDelay:Delay  = new Delay();
            
            //closure
            var onDrag:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                _latestPointer.setTo(Application.pointerX, Application.pointerY);
                var contains:Boolean = _latestHitArea.containsPoint(_latestPointer);
                
                updateDragElementPosition(x, y, contains);
                
                Controller.exec(klass, "onDrag", [x, y]);
                
                if (_latestHitArea.isEmpty())
                {
                    if (!rolloverDelay.running)
                         rolloverDelay.exec(tryRollover, configure.rolloverDelay, x, y);
                }
                else
                if (!contains)
                {
                    if (rolloverDelay.running)
                        rolloverDelay.cancel();
                    
                    rollout(x, y);
                    
                    _latestHitArea.setEmpty();
                }
            };
            
            var updateDragElementPosition:Function = function(x:NumberTracker, y:NumberTracker, contains:Boolean):void
            {
                if (contains && configure.absorbWhenRollover)
                {
                    clonedElement.x = _latestHitArea.x;
                    clonedElement.y = _latestHitArea.y;
                }
                else
                {
                    clonedElement.x = globalInitialPosition.x + x.totalDelta;
                    clonedElement.y = globalInitialPosition.y + y.totalDelta;
                }
            };
            
            var tryRollover:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                //(ヒットテストに成功すると_latestHitAreaの内容が書き換わる(emptyではなくなる))
                var  hitTestResult:ElementInfo = _eachHitTest();
                if (!hitTestResult)
                    return;
                
                if (configure.invisibleWhenRollover)
                    clonedElement.visible = false;
                
                params[1] = hitTestResult;
                params[3] = _latestHitArea.equals(_initialHitArea);
                Controller.exec(klass, "onRollover", params);
            };
            
            var rollout:Function = function(x:NumberTracker, y:NumberTracker):Boolean
            {
                if (configure.invisibleWhenRollover)
                    clonedElement.visible = true;
                
                params[3] = false;
                Controller.exec(klass, "onRollout", params);
                params[1] = null;
            };
            
            var onDrop:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                _latestPointer.setTo(Application.pointerX, Application.pointerY);
                var containsLatestPoint:Boolean = _latestHitArea.containsPoint(_latestPointer);
                
                //ドロップ時は遅延実行待ちにならば即座に結果を割り出す
                if (rolloverDelay.running)
                {
                    rolloverDelay.cancel();
                    tryRollover(x, y);
                }
                
                Controller.exec(klass, "onDrop", params);
                
                //後片付け
                clonedElement.destroy(true);
                parent.elementInfo.path.fetchView(starlingRoot).freeElementCache();
                if (mod) mod.ignorePointerDevice(false);
                _running = false;
            };
            
            //ドラッグしたオブジェクトの座標, サイズ情報を_latestHitAreaオブジェクトに与える為に一度ヒットテストを行っておく.
            _hitTestByElement(from, true);
            _initialHitArea = _latestHitArea.clone();
            
            //drag initialize
            from.toLocalPoint(_latestPointer, _TMP_POINT);
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
            
            each(function(e:IElement):Boolean
            {
                if (e && _hitTestByElement(e)) result = e.elementInfo;
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
            if (_TMP_RECT.containsPoint(_latestPointer))
            {
                _latestHitArea = _TMP_RECT.clone();
                return true;
            }
            else return false;
        }
    }
}