package jp.coremind.model
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    public class ElementModelAccessor
    {
        private static const _STORAGE:Object = {};
        
        private var _modelList:Object;
        
        public function ElementModelAccessor(storageId:String)
        {
            _modelList = storageId in _STORAGE ?
                _STORAGE[storageId]:
                _STORAGE[storageId] = new Dictionary(true);
        }
        
        public function destroy():void
        {
            for (var p:* in _modelList)
                removeModel(p);
            
            _modelList = null;
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
            var _removeModel:IElementModel = _modelList[model];
            delete _modelList[model];
            
            if (_removeModel)
                _removeModel.destroy();
        }
        
        public function addListener(model:Class, listener:Function, priority:int = 0):void
        {
            var instance:IElementModel = _modelList[model];
            if (instance) instance.addListener(listener, priority);
        }
        
        public function removeListener(model:Class, listener:Function):void
        {
            var instance:IElementModel = _modelList[model];
            if (instance) instance.removeListener(listener);
        }
        
        public function toString():String
        {
            return Log.toString(_modelList);
        }
    }
}