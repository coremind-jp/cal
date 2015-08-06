package jp.coremind.model
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    public class RuntimeModelAccessor
    {
        private static const _STORAGE:Object = {};
        
        private var _modelList:Object;
        
        public function RuntimeModelAccessor(storageId:String)
        {
            _modelList = storageId in _STORAGE ?
                _STORAGE[storageId]:
                _STORAGE[storageId] = new Dictionary(true);
        }
        
        public function destroy():void
        {
            _modelList = null;
        }
        
        internal function getModel(model:Class):IRuntimeModel
        {
            return _modelList[model];
        }
        
        internal function update(model:Class, ...params):void
        {
            var instance:IRuntimeModel = _modelList[model];
            if (instance) instance.update.apply(null, params);
        }
        
        public function isUndefined(model:Class):Boolean
        {
            return !(model in _modelList);
        }
        
        public function addModel(model:Class, instance:IRuntimeModel):void
        {
            _modelList[model] = instance;
        }
        
        public function removeModel(model:Class):void
        {
            var _removeModel:IRuntimeModel = _modelList[model];
            if (_removeModel)
            {
                _removeModel.destroy();
                delete _modelList[model];
            }
        }
        
        internal function removeAllModel(storageId:String):void
        {
            for (var p:* in _modelList) removeModel(p);
        }
        
        public function addListener(model:Class, listener:Function):void
        {
            var instance:IRuntimeModel = _modelList[model];
            if (instance) instance.addListener(listener);
        }
        
        public function removeListener(model:Class, listener:Function):void
        {
            var instance:IRuntimeModel = _modelList[model];
            if (instance) instance.removeListener(listener);
        }
        
        public function toString():String
        {
            return Log.toString(_modelList);
        }
    }
}