package jp.coremind.storage
{
    import jp.coremind.configure.IStorageConfigure;
    import jp.coremind.core.Application;
    import jp.coremind.core.Layer;
    import jp.coremind.event.TransitionEvent;
    import jp.coremind.utility.Log;

    public class ModelStorage
    {
        public static const UNDEFINED_STORAGE_ID:String = "undefinedStorageId";
        public static const TAG:String = "[Storage]";
        //Log.addCustomTag(TAG);
        
        public var destroyListener:Function;
        
        private var
            _writerCache:Object,
            _readerCache:Object,
            _storageContainer:Object;
        
        /**
         * アプリケーション内で利用される記憶領域への操作を制御するクラス.
         * @param   sharedObjectName    アプリケーションで利用するSharedObjectのドメイン名
         */
        public function ModelStorage(sharedObjectName:String = ""):void
        {
            _writerCache = {};
            _readerCache = {};
            
            _storageContainer = {};
            _storageContainer[StorageType.HASH]    = new HashStorage();
            _storageContainer[StorageType.SHARED]  = new SharedObjectStrage();
            _storageContainer[StorageType.SQ_LITE] = new SqLiteStorage();
            
            Application.globalEvent.addEventListener(TransitionEvent.END_TRANSITION, refresh);
        }
        
        /** 
         * パラメータtypeの基づいてIStorageインターフェースを実装したインスタンスを返す.
         * @param   type    ストレージタイプ(StorageType定数で指定)
         */
        private function _selectStorage(type:String):IModelStorage
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
        public function requestWriter(id:String, storageType:String = StorageType.HASH):ModelWriter
        {
            if (id in _writerCache)
                return _writerCache[id];
            else
            {
                _setup(id, storageType);
                return _writerCache[id] = new ModelWriter(id, storageType);
            }
        }
        
        /** 
         * パラメータidと対になるデータを読み取るStorageModeReaderインスタンスを返す.
         * @param   id              ストレージid。指定したidが見つからない場合、そのidを利用できるように領域を作成する
         * @param   type            ストレージタイプ(StorageType定数で指定)
         */
        public function requestReader(id:String, storageType:String = StorageType.HASH):ModelReader
        {
            if (id in _readerCache)
                return _readerCache[id];
            else
            {
                _setup(id, storageType);
                return  _readerCache[id] = new ModelReader(id, storageType);
            }
        }
        
        private function _setup(id:String, storageType:String = StorageType.HASH):void
        {
            var configure:IStorageConfigure = Application.configure.storage;
            
            if (!isDefined(id, storageType))
            {
                Log.custom(TAG, "create StorageModelReader("+id+")");
                _create(storageType, id, configure.createInitialValue(id));
            }
        }
        
        private function _create(type:String, id:String, value:*):void
        {
            var initialValue:* = value || {};
            Log.custom(TAG, "create("+type+")", id);//, "initialValue:", initialValue);
            _selectStorage(type).create(id, initialValue);
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
         * requestWriterメソッド, requestReaderメソッドで生成されたインスタンスを破棄する.
         * 領域自体を消す訳ではない。　領域自体を消したい場合はStorageModelのupdateで空データを入れる。
         */
        public function destroy(id:String, storageType:String = StorageType.HASH):void
        {
            var reader:ModelReader, writer:ModelWriter;
            Log.custom(TAG, "delete ", id);
            
            if (id in _writerCache)
            {
                writer = _writerCache[id];
                delete _writerCache[id];
                
                Log.custom(TAG, "\tModelWriter");
                writer.destroy();
            }
            
            if (id in _readerCache)
            {
                reader = _readerCache[id];
                delete _readerCache[id];
                
                Log.custom(TAG, "\tModelReader");
                reader.destroy();
            }
            
            if (id !== UNDEFINED_STORAGE_ID && destroyListener is Function)
                destroyListener(id);
        }
        
        /**
         * キャッシュされているModelReaderを走査し各インスタンスに対してリスナーが存在しないModelreaderを破棄する.
         */
        public function refresh(e:TransitionEvent = null):void
        {
            Log.custom("refresh");
            
            for (var id:String in _readerCache)
            {
                var  reader:ModelReader = _readerCache[id];
                if (!reader.hasListener()) destroy(id, reader.type);
            }
            
            if (e.layer == Layer.CONTENT)
            {
                dumpCachedModel();
                dumpCachedReader();
            }
        }
        
        /** 現存するStorageModelをダンプする. */
        public function dumpCachedModel():void { Log.info(_writerCache); }
        /** 現存するStorageModelReaderをダンプする. */
        public function dumpCachedReader():void { Log.info(_readerCache); }
        
        internal function read(accessor:ModelReader):*
        {
            Log.custom(TAG, "read("+accessor.type+")", accessor.id);
            return _selectStorage(accessor.type).read(accessor.id);
        }
        
        internal function update(accessor:ModelWriter, value:*):void
        {
            Log.custom(TAG, "update("+accessor.type+")", accessor.id, value);
            _selectStorage(accessor.type).update(accessor.id, value);
        }
    }
}