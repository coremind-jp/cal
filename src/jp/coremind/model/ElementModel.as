package jp.coremind.model
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    public class ElementModel
    {
        private var _moduleList:Dictionary;
        
        public function ElementModel()
        {
            _moduleList = new Dictionary(true);
        }
        
        public function destroy():void
        {
            for (var p:* in _moduleList)
                removeModule(p);
            
            _moduleList = null;
        }
        
        public function isUndefined(module:Class):Boolean
        {
            return !(module in _moduleList);
        }
        
        /** only use for StorageModel class. */
        public function getModule(model:Class):IElementModel
        {
            return _moduleList[model];
        }
        
        public function addModule(instance:IElementModel):void
        {
            _moduleList[$.getClassByInstance(instance)] = instance;
        }
        
        public function removeModule(module:Class):void
        {
            if (isUndefined(module)) return;
            else getModule(module).destroy();
            
            delete _moduleList[module];
        }
        
        public function addListener(module:Class, listener:Function, priority:int = 0):void
        {
            if (isUndefined(module)) return;
            else getModule(module).addListener(listener, priority);
        }
        
        public function removeListener(module:Class, listener:Function):void
        {
            if (isUndefined(module)) return;
            else getModule(module).removeListener(listener);
        }
        
        public function toString():String
        {
            return Log.toString(_moduleList);
        }
    }
}