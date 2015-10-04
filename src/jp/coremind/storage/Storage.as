package jp.coremind.storage
{
    import jp.coremind.configure.IStorageConfigure;
    import jp.coremind.core.Application;
    import jp.coremind.core.Layer;
    import jp.coremind.event.ViewTransitionEvent;
    import jp.coremind.model.ElementModel;
    import jp.coremind.utility.Log;

    public class Storage
    {
        public static const UNDEFINED_STORAGE_ID:String = "undefinedStorageId";
        public static const TAG:String = "[Storage]";
        //Log.addCustomTag(TAG);
        
        private var
            _modelCache:Object,
            _readerCache:Object,
            _elementModelStorage:ElementModelStorage,
            _storageContainer:Object;
        
        /**
         * アプリケーション内で利用される記憶領域への操作を制御するクラス.
         * @param   sharedObjectName    アプリケーションで利用するSharedObjectのドメイン名
         */
        public function Storage(sharedObjectName:String = ""):void
        {
            _modelCache   = {};
            _readerCache  = {};
            
            _elementModelStorage = new ElementModelStorage();
            
            _storageContainer = {};
            _storageContainer[StorageType.HASH]    = new HashStorage();
            _storageContainer[StorageType.SHARED]  = new SharedObjectStrage();
            _storageContainer[StorageType.SQ_LITE] = new SqLiteStorage();
            
            Application.globalEvent.addEventListener(ViewTransitionEvent.END_TRANSITION, refresh);
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
         */
        public function requestModel(id:String, storageType:String = StorageType.HASH):StorageModel
        {
            if (id in _modelCache) return _modelCache[id];
            else
            {
                _setupStorage(id, storageType);
                return _modelCache[id] = new StorageModel(id, storageType);
            }
        }
        
        /** 
         * パラメータidと対になるデータを読み取るStorageModeReaderインスタンスを返す.
         * @param   id              ストレージid。指定したidが見つからない場合、そのidを利用できるように領域を作成する
         * @param   type            ストレージタイプ(StorageType定数で指定)
         */
        public function requestModelReader(id:String, storageType:String = StorageType.HASH):StorageModelReader
        {
            if (id in _readerCache) return _readerCache[id];
            else
            {
                _setupStorage(id, storageType);
                return  _readerCache[id] = new StorageModelReader(id, storageType);
            }
        }
        
        private function _setupStorage(id:String, storageType:String = StorageType.HASH):void
        {
            var configure:IStorageConfigure = Application.configure.storage;
            
            if (!isDefined(id, storageType))
            {
                Log.custom(TAG, "create StorageModelReader("+id+")");
                _create(storageType, id, configure.createInitialValue(id));
            }
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
        
        /** 
         */
        public function requestElementModel(storageId:String, elementId:String):ElementModel
        {
            if (!_elementModelStorage.isDefined(storageId, elementId))
            {
                Log.custom(TAG, "create ElementModel(", storageId, elementId, ")");
                _elementModelStorage.create(storageId, elementId);
            }
            
            return _elementModelStorage.read(storageId, elementId);
        }
        
        public function deleteElementModel(elementId:String):void
        {
            if (_elementModelStorage.isDefined(UNDEFINED_STORAGE_ID, elementId))
            {
                Log.custom(TAG, "de1ete ElementModel(", elementId, ")");
                _elementModelStorage.de1ete(UNDEFINED_STORAGE_ID, elementId);
            }
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
            var reader:StorageModelReader, model:StorageModel, eModel:ElementModel;
            Log.custom(TAG, "delete ", id);
            
            if (id in _modelCache)
            {
                model = _modelCache[id];
                delete _modelCache[id];
                
                Log.custom(TAG, "\tStorageModel");
                model.destroy();
            }
            
            if (id in _readerCache)
            {
                reader = _readerCache[id];
                delete _readerCache[id];
                
                Log.custom(TAG, "\tStorageModelReader");
                reader.destroy();
            }
            
            if (id !== UNDEFINED_STORAGE_ID)
                _elementModelStorage.de1ete(id);
        }
        
        public function refresh(e:ViewTransitionEvent = null):void
        {
            Log.custom("refresh");
            
            for (var id:String in _readerCache)
            {
                var reader:StorageModelReader = _readerCache[id];
                if (!reader.hasListener()) de1ete(id, reader.type);
            }
            
            if (e.layer == Layer.CONTENT)
            {
                dumpCachedModel();
                dumpCachedReader();
            }
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