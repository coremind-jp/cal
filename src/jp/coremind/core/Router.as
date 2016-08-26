package jp.coremind.core
{
    import jp.coremind.controller.Controller;
    import jp.coremind.controller.DragAndDropConfigure;
    import jp.coremind.controller.DragAndDropController;
    import jp.coremind.controller.SliderConfigure2D;
    import jp.coremind.controller.SliderController;
    import jp.coremind.event.ElementInfo;
    import jp.coremind.module.StatusGroup;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;

    public class Router
    {
        public static const TAG:String = "Router";
        Log.addCustomTag(TAG);
        
        public static var _LISTENER_LIST:Object;
        
        public function Router()
        {
            _LISTENER_LIST = {};
        }
        
        public function listenStatus(controllerClass:Class, method:String, path:Array, statusGroup:String, statusValue:String, staticParams:Array = null):void
        {
            Controller.bindView(path[1], controllerClass);
            
            var key:String = ElementPathParser.createRouterKey(path, statusGroup, statusValue);
            if (key in _LISTENER_LIST)
                Log.warning("already defined Executor.", arguments);
            else
            {
                _LISTENER_LIST[key] = new Executor(controllerClass, method, staticParams);
                Log.custom(TAG, "success defined Routing.", key, "=>", controllerClass, "::", method);
            }
        }
        
        public function listenDrag(dragTargetList:Array, configure:DragAndDropConfigure):void
        {
            if (configure.controllerClass)
            {
                var confId:int = DragAndDropController.addConfigure(configure);
                var params:Array = [confId];
                
                for (var i:int = 0; i < dragTargetList.length; i++) 
                {
                    Controller.bindView(dragTargetList[i][1], configure.controllerClass);
                    listenStatus(DragAndDropController, "beginDrag", dragTargetList[i], StatusGroup.PRESS, Status.DOWN, params);
                }
            }
        }
        
        public function listenSlider(configure:SliderConfigure2D, path:Array):void
        {
            configure.createSlideAreaRectangle();
            
            var confId:int = SliderController.addConfigure(configure);
            var params:Array = [confId];
            
            listenStatus(SliderController, "beginSlide", path, StatusGroup.PRESS, Status.DOWN, params);
        }
        
        public function notify(info:ElementInfo, statusGroup:String, statusValue:String):void
        {
            var executor:Executor;
            
            executor = getExecutor(info.path.createRouterKey(statusGroup, statusValue));
            if (executor) executor.exec(info);
            else
            {
                executor = searchBuzzElementIdExecutor(info, statusGroup, statusValue);
                if (executor) executor.exec(info);
                //else Log.info("undefined Executor.", info);
            }
        }
        
        public function searchBuzzElementIdExecutor(info:ElementInfo, statusGroup:String, statusValue:String):Executor
        {
            var elementPath:Array  = info.path.elementId.split(".");
            var elementName:String = elementPath[elementPath.length-1];
            
            if (elementName.match(/^[0-9]+$/))
            {
                elementPath.splice(-1, 1, "{n}");
                
                return getExecutor(info.path.createRouterKey(statusGroup, statusValue)
                          .replace(info.path.elementId, elementPath.join(".")));
            }
            else
                return null;
        }
        
        public function getExecutor(uniqueId:String):Executor
        {
            //Log.custom(TAG, "dump uniqueId:", uniqueId);
            return uniqueId in _LISTENER_LIST ? _LISTENER_LIST[uniqueId]: null;
        }
    }
}
import jp.coremind.controller.Controller;

class Executor
{
    private var
        _controllerClass:Class,
        _method:String,
        _staticParams:Array;
        
    public function Executor(controllerClass:Class, method:String, staticParams:Array = null)
    {
        _controllerClass = controllerClass;
        _method          = method;
        _staticParams    = staticParams;
    }
    
    public function exec(...extendParams):void
    {
        var p:Array = _staticParams ?
            extendParams.length > 0 ? extendParams.concat(_staticParams): _staticParams:
            extendParams;
        
        Controller.exec(_controllerClass, _method, p);
    }
}