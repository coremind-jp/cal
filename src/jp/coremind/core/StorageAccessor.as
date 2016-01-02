package jp.coremind.core
{
    import flash.events.EventDispatcher;
    
    import jp.coremind.model.ElementModel;
    import jp.coremind.storage.Storage;
    import jp.coremind.storage.StorageModelReader;

    public class StorageAccessor extends EventDispatcher
    {
        private static var _STORAGE:Storage;
        
        public  static function initialize(storage:Storage):void
        {
            _STORAGE = storage;
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public static function requestModelReader(storageId:String):StorageModelReader
        {
            return _STORAGE.requestModelReader(storageId, Application.configure.storage.getStorageType(storageId));
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public static function requestElementModel(storageId:String, elementId:String):ElementModel
        {
            return _STORAGE.requestElementModel(storageId, elementId);
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public static function deleteElementModel(elementId:String):void
        {
            _STORAGE.deleteElementModel(elementId);
        }
        
        protected function get storage():Storage
        {
            return _STORAGE;
        }
    }
}