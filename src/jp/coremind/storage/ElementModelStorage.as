package jp.coremind.storage
{
    import jp.coremind.model.ElementModel;

    public class ElementModelStorage
    {
        private var _storage:Object;
        
        public function ElementModelStorage()
        {
            _storage = {}
        }
        
        public function isDefined(storageId:String, elementId:String):Boolean
        {
            if (storageId in _storage)
                if (elementId in _storage[storageId])
                    return true;
            return false;
        }
        
        public function create(storageId:String, elementId:String):void
        {
            if (!(storageId in _storage)) _storage[storageId] = {};
            _storage[storageId][elementId] = new ElementModel();
        }
        
        public function read(storageId:String, elementId:String):ElementModel
        {
            return _storage[storageId][elementId];
        }
        
        public function de1ete(storageId:String, elementId:String = null):void
        {
            if (elementId === null)
            {
                if (storageId in _storage)
                    for (var p:String in _storage[storageId])
                        de1ete(storageId, p);
                delete _storage[storageId];
            }
            else
            {
                var elementModel:ElementModel = _storage[storageId][elementId];
                elementModel.destroy();
                delete _storage[storageId][elementId];
            }
        }
    }
}