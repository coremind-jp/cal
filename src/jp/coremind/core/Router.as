package jp.coremind.core
{
    import jp.coremind.event.ElementInfo;
    import jp.coremind.utility.Log;

    public class Router
    {
        public static var _LISTENER_LIST:Object;
        
        public function Router()
        {
            _LISTENER_LIST = {};
        }
        
        public function listen(controllerClass:Class, method:String, viewId:String, elementId:Array, statusGroup:String, statusValue:String):void
        {
            Controller.bindView(viewId, controllerClass);
            
            var uniqueId:String = viewId + elementId.join(".") + statusGroup + statusValue;
            if (uniqueId in _LISTENER_LIST)
                Log.warning("already defined Executor.", arguments);
            else
            {
                _LISTENER_LIST[uniqueId] = new Executor(controllerClass, method);
                Log.info("success defined Executor.", uniqueId, controllerClass, method);
            }
        }
        
        public function notify(elementInfo:ElementInfo, statusGroup:String, statusValue:String):void
        {
            var executor:Executor;
            
            executor = getExecutor(elementInfo.createRouterKey(statusGroup, statusValue));
            if (executor) executor.exec(elementInfo);
            else
            {
                executor = searchBuzzElementIdExecutor(elementInfo, statusGroup, statusValue);
                if (executor) executor.exec(elementInfo);
                //else Log.info("undefined Executor.", elementInfo);
            }
        }
        
        public function searchBuzzElementIdExecutor(elementInfo:ElementInfo, statusGroup:String, statusValue:String):Executor
        {
            var elementPath:Array  = elementInfo.elementId.split(".");
            var elementName:String = elementPath[elementPath.length-1];
            
            if (elementName.match(/^[0-9]+$/))
            {
                elementPath.splice(-1, 1, "{n}");
                
                return getExecutor(elementInfo.createRouterKey(statusGroup, statusValue)
                    .replace(elementInfo.elementId, elementPath.join(".")));
            }
            else
                return null;
        }
        
        public function getExecutor(uniqueId:String):Executor
        {
            return uniqueId in _LISTENER_LIST ? _LISTENER_LIST[uniqueId]: null;
        }
    }
}
import jp.coremind.core.Controller;

class Executor
{
    private var
        _controllerClass:Class,
        _method:String;
        
    public function Executor(controllerClass:Class, method:String)
    {
        _controllerClass = controllerClass;
        _method = method;
    }
    
    public function exec(...params):void
    {
        Controller.exec(_controllerClass, _method, params);
    }
}