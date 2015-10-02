package jp.coremind.core
{
    import flash.utils.Dictionary;
    
    import jp.coremind.model.IElementModel;
    import jp.coremind.utility.Log;

    public class ElementModelAccessor
    {
        private static const _STORAGE:Object = {};
        
        private var _modelList:Object;
        
        public function ElementModelAccessor()
        {
        }
        
        public function destroy():void
        {
            for (var p:* in _modelList)
                removeModel(p);
            
            _modelList = null;
        }
        
        protected function requestElementModel(storageId:String):Dictionary
        {
            return storageId in _STORAGE ?
                _STORAGE[storageId]:
                _STORAGE[storageId] = new Dictionary(true);
        }
        
        /** only use for StorageModel class. */
        internal function getModel(model:Class):IElementModel
        {
            return _modelList[model];
        }
        
        public function isUndefined(model:Class):Boolean
        {
            return !(model in _modelList);
        }
        
        public function addModel(instance:IElementModel):void
        {
            _modelList[$.getClassByInstance(instance)] = instance;
        }
        
        public function removeModel(model:Class):void
        {
            if (isUndefined(model)) return;
            else getModel(model).destroy();
            
            delete _modelList[model];
        }
        
        public function initialize(storageId:String):void
        {
            _modelList = storageId in _STORAGE ?
                _STORAGE[storageId]:
                _STORAGE[storageId] = new Dictionary(true);
        }
        
        public function addListener(model:Class, listener:Function, priority:int = 0):void
        {
            if (isUndefined(model)) return;
            else getModel(model).addListener(listener, priority);
        }
        
        public function removeListener(model:Class, listener:Function):void
        {
            if (isUndefined(model)) return;
            else getModel(model).removeListener(listener);
        }
        
        public function toString():String
        {
            return Log.toString(_modelList);
        }
    }
}