package jp.coremind.event
{
    import jp.coremind.core.ElementPathParser;
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.module.ModuleList;
    import jp.coremind.storage.IModelStorageListener;
    import jp.coremind.storage.ModelReader;
    import jp.coremind.storage.ModelStorage;
    import jp.coremind.utility.Log;

    public class ElementInfo
    {
        public static const TAG:String = "[ElementInfo]";
        Log.addCustomTag(TAG);
        
        private var
            _reader:ModelReader,
            _modules:ModuleList,
            _storageId:String,
            _pathParser:ElementPathParser;
        
        public function ElementInfo()
        {
            _storageId  = ModelStorage.UNDEFINED_STORAGE_ID;
            _pathParser = new ElementPathParser();
        }
        
        public function clone():ElementInfo
        {
            var result:ElementInfo = new ElementInfo();
            
            result._reader     = _reader;
            result._modules    = _modules;
            result._storageId  = _storageId;
            result._pathParser = _pathParser;
            
            return result;
        }
        
        public function get reader():ModelReader { return _reader; }
        public function get storageId():String { return _storageId; }
        public function setReader(storageId:String, listener:IModelStorageListener):void
        {
            _storageId = storageId && storageId.length > 0 ?
                storageId:
                ModelStorage.UNDEFINED_STORAGE_ID;
            
            _reader = StorageAccessor.requestReader(_storageId);
            _reader.addListener(listener, ModelReader.LISTENER_PRIORITY_ELEMENT);
        }
        
        public function resetReader(listener:IModelStorageListener):void
        {
            if (_reader) _reader.removeListener(listener);
            
            _reader    = null;
            _storageId = ModelStorage.UNDEFINED_STORAGE_ID;
        }
        
        public function reset(listener:IModelStorageListener):void
        {
            resetReader(listener);
            
            _modules   = null;
            _pathParser.initialize("unknown", "unknown", "unknown");
        }
        
        public function get modules():ModuleList { return _modules; }
        
        public function changeIdSuffix(suffix:String, listener:IModelStorageListener):void
        {
            if (!_modules || !_reader) return;
            
            var splitedStorageId:Array = _storageId.split(".");
            if (splitedStorageId.length == 1) return;
            splitedStorageId[splitedStorageId.length-1] = suffix;
            var newStorageId:String = splitedStorageId.join(".");
            
            var splitedElementId:Array = _pathParser.elementId.split(".");
            if (splitedElementId.length == 1) return;
            splitedElementId[splitedElementId.length-1] = suffix;
            var newElementId:String = splitedElementId.join(".");
            
            StorageAccessor.overwriteModuleList(
                _storageId, _pathParser.elementId, newStorageId, newElementId, _modules);
            
            //update PathParser
            _pathParser.initialize(_pathParser.layerId, _pathParser.viewId, newElementId);
            
            //update ModelReader
            resetReader(listener);
            setReader(newStorageId, listener);
            
            //update ModuleList
            _modules = StorageAccessor.requestModule(newStorageId, newElementId);
            
            Log.custom(TAG, "changeModulesReferenceByIdSuffix",　this);
        }
        
        public function loadModules():void
        {
            _modules = StorageAccessor.requestModule(_storageId, _pathParser.elementId);
            Log.custom(TAG, "loadedModules",　this);
        }
        
        public function get path():ElementPathParser
        {
            return _pathParser;
        }
        
        public function toString():String
        {
            return "storageId:" + _storageId + " " + _pathParser.toString();
        }
    }
}