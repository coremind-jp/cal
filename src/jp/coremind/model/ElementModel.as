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
        
        public function getModule(module:Class):IElementModel
        {
            if (isUndefined(module))
            {
                Log.error("undefined ElementModelModule", module);
                return null;
            }
            else
                return _moduleList[module];
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
        
        public function toString():String
        {
            return Log.toString(_moduleList);
        }
    }
}