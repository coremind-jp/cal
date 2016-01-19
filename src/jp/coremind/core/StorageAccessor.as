package jp.coremind.core
{
    import jp.coremind.module.ModuleList;
    import jp.coremind.storage.ModelReader;
    import jp.coremind.storage.ModelStorage;
    import jp.coremind.storage.ModuleStorage;
    import jp.coremind.utility.Log;

    public class StorageAccessor
    {
        public static const TAG:String = "[StorageAccessor]";
        Log.addCustomTag(TAG);
        
        private static const _MODULE:ModuleStorage = new ModuleStorage();
        private static var   _MODEL:ModelStorage;
        
        public  static function initialize(storage:ModelStorage):void
        {
            _MODEL = storage;
            _MODEL.destroyListener = _MODULE.destroy;
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public static function requestReader(storageId:String):ModelReader
        {
            return _MODEL.requestReader(storageId, Application.configure.storage.getStorageType(storageId));
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public static function requestModule(storageId:String, elementId:String):ModuleList
        {
            if (!_MODULE.isDefined(storageId, elementId)) _MODULE.create(storageId, elementId);
            return _MODULE.read(storageId, elementId);
        }
        
        public static function overwriteModuleList(
            storageId:String, elementId:String,
            newStorageId:String, newElementId,
            currentModule:ModuleList):void
        {
            Log.custom(TAG, "overwriteModuleList",
                "\nfrom:", storageId, elementId,
                "\n  to:", newStorageId, newElementId);
            
            var realModule:ModuleList = _MODULE.purge(storageId, elementId);
            
            if (realModule !== currentModule)
                Log.warning("different reference trying to overwrite ModuleList");
            
            if (_MODULE.isDefined(storageId, elementId))
                Log.warning("already defined ModuleList. but overwrited.", storageId, elementId);
            
            _MODULE.create(newStorageId, newElementId, currentModule);
        }
        
        protected function get storage():ModelStorage
        {
            return _MODEL;
        }
    }
}