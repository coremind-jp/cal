package jp.coremind.storage
{
    import jp.coremind.model.ModuleList;
    import jp.coremind.utility.Log;

    public class ModuleStorage
    {
        public static const TAG:String = "[ModuleStorage]";
        Log.addCustomTag(TAG);
        
        private var _storage:Object;
        
        public function ModuleStorage()
        {
            _storage = {}
        }
        
        public function isDefined(storageId:String, elementId:String):Boolean
        {
            return storageId in _storage && elementId in _storage[storageId];
        }
        
        public function create(storageId:String, elementId:String, modulList:ModuleList = null):void
        {
            if (!(storageId in _storage)) _storage[storageId] = {};
            _storage[storageId][elementId] = modulList || new ModuleList();
        }
        
        public function read(storageId:String, elementId:String):ModuleList
        {
            return _storage[storageId][elementId];
        }
        
        public function purge(storageId:String, elementId:String):ModuleList
        {
            Log.custom(TAG, "purge", storageId, elementId);
            
            var purgedModuleList:ModuleList;
            if (storageId in _storage && elementId in _storage[storageId])
            {
                purgedModuleList = _storage[storageId][elementId];
                delete _storage[storageId][elementId];
            }
            
            return purgedModuleList;
        }
        
        public function destroy(storageId:String, elementId:String = null):void
        {
            Log.custom(TAG, "destroy", storageId, elementId);
            
            if (elementId === null)
            {
                if (storageId in _storage)
                    for (var p:String in _storage[storageId])
                        destroy(storageId, p);
                delete _storage[storageId];
            }
            else
            {
                var modules:ModuleList = _storage[storageId][elementId];
                modules.destroy();
                delete _storage[storageId][elementId];
            }
        }
    }
}