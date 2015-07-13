package jp.coremind.model
{
    import jp.coremind.model.storage.HashStorage;
    import jp.coremind.model.storage.IStorage;
    import jp.coremind.model.storage.SharedObjectStrage;
    import jp.coremind.model.storage.SqLiteStorage;
    import jp.coremind.model.storage.StorageType;
    import jp.coremind.utility.Log;

    public class StorageControl
    {
        public static const TAG:String = "StorageControl";
        Log.addCustomTag(TAG);
        
        private var
            _sqLite:SqLiteStorage,
            _runtime:HashStorage,
            _view:HashStorage,
            _sharedObject:IStorage;
        
        public function StorageControl()
        {
            _sqLite = new SqLiteStorage();
            _sqLite.reset();
            
            _runtime = new HashStorage();
            _runtime.reset();
            
            _view = new HashStorage();
            _view.reset();
            
            _sharedObject = new SharedObjectStrage();
            _sharedObject.reset();
        }
        
        private function _selectStorage(type:String):IStorage
        {
            switch (type)
            {
                default:
                case StorageType.VIEW_HASH: return _view;
                case StorageType.RUNTIME_HASH: return _runtime;
                case StorageType.SHARED:  return _sharedObject;
                case StorageType.SQ_LITE: return _sqLite;
            }
        }
        
        public function createAccessor(globalId:String, initialValue:* = null, storageType:String = StorageType.RUNTIME_HASH):StorageAccessor
        {
            Log.custom("create("+storageType+")", globalId, "initialValue:", initialValue);
            
            var accessor:StorageAccessor = new StorageAccessor(globalId, storageType);
            if (initialValue)
                _selectStorage(accessor.type).create(accessor.globalId, initialValue);
            
            return accessor;
        }
        
        public function read(accessor:StorageAccessor):*
        {
            var v:* = _selectStorage(accessor.type).read(accessor.globalId);
            return v;
        }
        
        public function update(accessor:StorageAccessor, value:*):void
        {
            Log.custom("update("+accessor.type+")", accessor.globalId);
            _selectStorage(accessor.type).update(accessor.globalId, value);
        }
        
        public function de1ete(accessor:StorageAccessor):void
        {
            Log.custom("de1ete("+accessor.type+")", accessor.globalId);
            _selectStorage(accessor.type).de1ete(accessor.globalId);
        }
    }
}