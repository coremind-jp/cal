package jp.coremind.model
{
    import jp.coremind.utility.Log;

    public class Storage
    {
        public static const TAG:String = "[Storage]";
        //Log.addCustomTag(TAG);
        
        private var
            _modelCache:Object,
            _readerCache:Object,
            _storageContainer:Object;
        
        /**
         * アプリケーション内で利用される記憶領域への操作を制御するクラス.
         * @param   sharedObjectName    アプリケーションで利用するSharedObjectのドメイン名
         */
        public function Storage(sharedObjectName:String = ""):void
        {
            _modelCache  = {};
            _readerCache = {};
            
            _storageContainer = {};
            _storageContainer[StorageType.HASH]    = new HashStorage();
            _storageContainer[StorageType.SHARED]  = new SharedObjectStrage();
            _storageContainer[StorageType.SQ_LITE] = new SqLiteStorage();
        }
        
        /** 
         * パラメータtypeの基づいてIStorageインターフェースを実装したインスタンスを返す.
         * @param   type    ストレージタイプ(StorageType定数で指定)
         */
        private function _selectStorage(type:String):IStorage
        {
            if (type in _storageContainer)
                return _storageContainer[type];
            else
            {
                Log.error("unknown StorageType", type);
                return _storageContainer[StorageType.HASH];
            }
        }
        
        /** 
         * パラメータidと対になるデータを制御するStorageModeインスタンスを返す.
         * @param   id              ストレージid。指定したidが見つからない場合、そのidを利用できるように領域を作成する
         * @param   type            ストレージタイプ(StorageType定数で指定)
         * @param   initialValue    idが見つからなかった場合に作成された領域に設定する初期値
         */
        public function requestModel(id:String, storageType:String = StorageType.HASH, initialValue:* = null):StorageModel
        {
            var model:StorageModel;
            
            if (id in _modelCache)
                model = _modelCache[id];
            else
            {
                Log.custom(TAG, "create StorageModel("+id+")");
                if (_selectStorage(storageType).read(id) === undefined)
                    _create(storageType, id, initialValue);
                
                model = _modelCache[id] = new StorageModel(id, storageType, initialValue);
            }
            
            return model;
        }
        
        /** 
         * パラメータidと対になるデータを読み取るStorageModeReaderインスタンスを返す.
         * @param   id              ストレージid。指定したidが見つからない場合、そのidを利用できるように領域を作成する
         * @param   type            ストレージタイプ(StorageType定数で指定)
         * @param   initialValue    idが見つからなかった場合に作成された領域に設定する初期値
         */
        public function requestModelReader(id:String, storageType:String = StorageType.HASH, initialValue:* = null):StorageModelReader
        {
            var reader:StorageModelReader;
            
            if (id in _readerCache)
                reader = _readerCache[id];
            else
            {
                Log.custom(TAG, "create StorageModelReader("+id+")");
                if (_selectStorage(storageType).read(id) === undefined)
                    _create(storageType, id, initialValue);
                
                reader = _readerCache[id] = new StorageModelReader(id, storageType);
            }
            
            return reader;
        }
        
        /** 
         * パラメータidと対になるStorageModeインスタンスが定義(作成)済みかを示す値を返す.
         * @param   id              ストレージid。指定したidが見つからない場合、そのidを利用できるように領域を作成する
         * @param   type            ストレージタイプ(StorageType定数で指定)
         */
        public function isDefined(storageId, type:String):Boolean
        {
            return _selectStorage(type).isDefined(storageId);
        }
        
        /** 現存するStorageModelをダンプする. */
        public function dumpCachedModel():void { Log.info(_modelCache); }
        /** 現存するStorageModelReaderをダンプする. */
        public function dumpCachedReader():void { Log.info(_readerCache); }
        
        /**
         * requestModelメソッド, requestModelReaderメソッドで生成されたインスタンスを破棄する.
         * 領域自体を消す訳ではない。　領域自体を消したい場合はStorageModelのupdateで空データを入れる。
         */
        public function de1ete(id:String, storageType:String = StorageType.HASH):void
        {
            var reader:StorageModelReader, model:StorageModel;
            
            if (id in _modelCache)
            {
                model = _modelCache[id];
                delete _modelCache[id];
                
                Log.custom(TAG, "de1ete StorageModel("+id+")", model, _modelCache[id]);
                model.destroy();
            }
            
            if (id in _readerCache)
            {
                reader = _readerCache[id];
                delete _readerCache[id];
                
                Log.custom(TAG, "de1ete StorageModelReader("+id+")", reader, _readerCache[id]);
                reader.destroy();
            }
        }
        
        public function refresh():void
        {
            Log.custom("refresh");
            
            for (var id:String in _readerCache)
            {
                var reader:StorageModelReader = _readerCache[id];
                if (!reader.hasListener()) de1ete(id, reader.type);
            }
            
//            dumpCachedModel();
//            dumpCachedReader();
        }
        
        private function _create(type:String, id:String, value:*):void
        {
            var initialValue:* = value || {};
            Log.custom(TAG, "create("+type+")", id);//, "initialValue:", initialValue);
            _selectStorage(type).create(id, initialValue);
        }
        
        internal function read(accessor:StorageModelReader):*
        {
            Log.custom(TAG, "read("+accessor.type+")", accessor.id);
            return _selectStorage(accessor.type).read(accessor.id);
        }
        
        internal function update(accessor:StorageModel, value:*):void
        {
            Log.custom(TAG, "update("+accessor.type+")", accessor.id);
            _selectStorage(accessor.type).update(accessor.id, value);
        }
    }
}