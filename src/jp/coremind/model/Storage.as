package jp.coremind.model
{
    import jp.coremind.utility.Log;

    public class Storage
    {
        public static const TAG:String = "[Storage]";
        Log.addCustomTag(TAG);
        
        private static const _STORAGE:Object = {};
        _STORAGE[StorageType.HASH]    = new HashStorage();
        _STORAGE[StorageType.SHARED]  = new SharedObjectStrage();
        _STORAGE[StorageType.SQ_LITE] = new SqLiteStorage();
        
        private static function _selectStorage(type:String):IStorage
        {
            if (type in _STORAGE)
                return _STORAGE[type];
            else
            {
                Log.error("unknown StorageType", type);
                return _STORAGE[StorageType.HASH];
            }
        }
        
        private static const _MODEL_CACHE:Object  = {};
        public static function requestModel(id:String, storageType:String = StorageType.HASH, initialValue:* = null):StorageModel
        {
            var model:StorageModel;
            
            if (id in _MODEL_CACHE)
                model = _MODEL_CACHE[id];
            else
            {
                Log.custom(TAG, "create StorageModel("+id+")");
                if (_selectStorage(storageType).read(id) === undefined)
                    _create(storageType, id, initialValue);
                
                model = _MODEL_CACHE[id] = new StorageModel(id, storageType, initialValue);
            }
            
            return model;
        }
        public function dumpCachedModel():void { Log.info(_MODEL_CACHE); }
        
        private static const _READER_CACHE:Object = {};
        public static function requestModelReader(id:String, storageType:String = StorageType.HASH, initialValue:* = null):StorageModelReader
        {
            var reader:StorageModelReader;
            
            if (id in _READER_CACHE)
                reader = _READER_CACHE[id];
            else
            {
                Log.custom(TAG, "create StorageModelReader("+id+")");
                if (_selectStorage(storageType).read(id) === undefined)
                    _create(storageType, id, initialValue);
                
                reader = _READER_CACHE[id] = new StorageModelReader(id, storageType);
            }
            
            return reader;
        }
        public function dumpCachedReader():void { Log.info(_READER_CACHE); }
        
        internal static function de1ete(id:String, storageType:String = StorageType.HASH):void
        {
            //deleteメソッドは実際のデータを削除するわけではなくModelを破棄する.
            //※配列、(ハッシュ配列)などの要素の削除はupdateで参照を上書きするので都度delete処理を呼ぶわけではない。
            
            if (id in _MODEL_CACHE)
            {
                Log.custom(TAG, "create StorageModel("+id+")");
                (_MODEL_CACHE[id] as StorageModel).destroy();
                delete _MODEL_CACHE[id];
            }
            
            if (id in _READER_CACHE)
            {
                Log.custom(TAG, "de1ete StorageModelReader("+id+")");
                (_READER_CACHE[id] as StorageModelReader).destroy();
                delete _READER_CACHE[id];
            }
        }
        
        private static function _create(type:String, id:String, value:*):void
        {
            var initialValue:* = value || {};
            Log.custom(TAG, "create("+type+")", id);//, "initialValue:", initialValue);
            _selectStorage(type).create(id, initialValue);
        }
        
        internal static function read(accessor:StorageModelReader):*
        {
            Log.custom(TAG, "read("+accessor.type+")", accessor.id);
            return _selectStorage(accessor.type).read(accessor.id);
        }
        
        internal static function update(accessor:StorageModel, value:*):void
        {
            Log.custom(TAG, "update("+accessor.type+")", accessor.id);
            _selectStorage(accessor.type).update(accessor.id, value);
        }
    }
}