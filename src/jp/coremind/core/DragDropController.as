package jp.coremind.core
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.event.ElementInfo;
    import jp.coremind.module.ModuleList;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.ContainerWrapper;
    import jp.coremind.view.implement.starling.component.ListContainer;
    import jp.coremind.view.interaction.Drag;
    
    import starling.core.Starling;
    
    public class DragDropController extends Controller
    {
        private static var _CONFIGURE_LIST:Array = [];
        public static function addConfigure(controllerClass:Class, absorb:Boolean, dropArea:Array):int
        {
            return _CONFIGURE_LIST.push(new Configure(controllerClass, absorb, dropArea)) - 1;
        }
        
        private var
            _initialHitArea:Rectangle,
            _latestHitArea:Rectangle,
            _currentConfigure:Configure;
        
        public function beginDrag(info:ElementInfo, confId:int):void
        {
            var dragElement:IElement = info.path.fetchElement(starlingRoot);
            if (dragElement)
            {
                _currentConfigure = _CONFIGURE_LIST[confId];
                
                if (dragElement is ContainerWrapper)
                    Log.warning("ContainerWrapper(SuperClass) not Supported Drag.");
                else
                if (Controller.exec(_currentConfigure.controllerClass, "dragFiltering", [info]))
                    _beginDrag(dragElement);
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
                Controller.exec(cls, "onDrag", [x, y]);
                
                //同期処理中の場合は処理しない
                if (Application.sync.isRunning())
                    return;
                
                //最後にヒットテストに成功したオブジェクトとの当たり判定がある内は処理しない
                if (_latestHitArea.containsPoint(Application.pointer))
                {
                    if (_currentConfigure.absorb)
                    {
                        clonedElement.x = _latestHitArea.x;
                        clonedElement.y = _latestHitArea.y;
                    }
                    return;
                }
                
                //最後にヒットテストに成功したオブジェクトとの当たり判定がない場合はそれが初回かを調べる
                if (params[1] !== null)
                {
                    params[3] = false;
                    Controller.exec(cls, "onRollout", params);
                    params[1] = null;
                    
                    _latestHitArea.setEmpty();
                    return;
                }
                
                //どのオブジェクトともヒットテストに成功しない場合, ドラッグ毎にヒットテストを繰り返す
                //ヒットテストに成功すると_latestHitAreaの内容が書き換わるのでこれ以降の処理は連続して呼ばれることはない
                var hitTestResult:ElementInfo = _eachHitTest();
                if (hitTestResult)
                {
                    params[1] = hitTestResult;
                    params[3] = _initialHitArea.containsPoint(Application.pointer);
                    Controller.exec(cls, "onRollover", params);
                }
            };
            
            var onDrop:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                if (Application.sync.isRunning())
                    Application.sync.pushQue(function():void { onDrop(x, y); });
                else
                {
                    Controller.exec(cls, "onDrop", params);
                    clonedElement.destroy(true);
                }
            };
            
            var clonedElement:IElement = from.clone();
            var globalInitialPosition:Point = from.toGlobalPoint(new Point());
            clonedElement.x = globalInitialPosition.x;
            clonedElement.y = globalInitialPosition.y;
            
            
            //closure variable
            var cls:Class    = _currentConfigure.controllerClass;
            var params:Array = [from.elementInfo, from.elementInfo, clonedElement.elementInfo, false];
            
            
            var layerRoot:ICalSprite   = Starling.current.stage.getChildAt(0) as ICalSprite;
            var systemLayer:ICalSprite = layerRoot.getDisplayByName(Layer.SYSTEM) as ICalSprite;
            systemLayer.addDisplay(clonedElement);
            //clonedElement.elementInfo.modules.getModule(StatusModel).update(StatusGroup.PRESS, Status.DOWN);
            
            from.toLocalPoint(Application.pointer, _TMP_POINT);
            _TMP_RECT.setTo(_TMP_POINT.x, _TMP_POINT.y, from.elementWidth, from.elementHeight);
            
            var dragger:Drag = new Drag(0);
            dragger.initialize(_TMP_RECT, new Rectangle(0, 55, 320, 568 - 55), onDrag, onDrop);
            dragger.beginPointerDeviceListening();
            
            Controller.exec(cls, "onDragBegin", params);
        }
        
        private function _eachHitTest():ElementInfo
        {
            var list:Array = _currentConfigure.dropAreaList;
            
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
            if (!ignoreFiltering && !Controller.exec(_currentConfigure.controllerClass, "dropFiltering", [e.elementInfo]))
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
import jp.coremind.core.ElementPathParser;

class Configure
{
    public var
        controllerClass:Class,
        absorb:Boolean,
        dropAreaList:Array;
    
    public function Configure(controllerClass:Class, absorb:Boolean, dropAreaList:Array)
    {
        this.controllerClass = controllerClass;
        this.absorb          = absorb;
        this.dropAreaList    = _convertDropAreaList(dropAreaList);
    }
    
    private function _convertDropAreaList(list:Array):Array
    {
        for (var i:int = 0; i < list.length; i++) 
            list[i] is Array ?
                list[i] = new ElementPathParser()
                    .initialize(list[i].shift(), list[i].shift(), list[i].join(".")):
                list.splice(i--, 1);
        
        return list;
    }
}