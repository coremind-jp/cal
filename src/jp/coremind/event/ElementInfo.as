package jp.coremind.event
{
    import jp.coremind.core.ElementPathParser;
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.model.ModuleList;
    import jp.coremind.storage.ModelReader;
    import jp.coremind.storage.ModelStorage;
    import jp.coremind.utility.Log;

    public class ElementInfo
    {
        public static const TAG:String = "[ElementInfo]";
        Log.addCustomTag(TAG);
        
        private var
            _modules:ModuleList,
            _storageId:String,
            _pathParser:ElementPathParser;
        
        public function ElementInfo(storageId:String)
        {
            _storageId  = storageId;
            _pathParser = new ElementPathParser();
        }
        
        public function get reader():ModelReader
        {
            if (_storageId)
                return StorageAccessor.requestReader(_storageId);
            else
            {
                Log.custom(TAG, "undefined storageId", this);
                return StorageAccessor.requestReader(ModelStorage.UNDEFINED_STORAGE_ID);
            }
        }
        
        public function get modules():ModuleList
        {
            return _modules;
        }
        
        public function initialize(layerId:String, viewId:String, elementId:String, idSuffix:String):void
        {
            if (_modules)
            {
                var b:ModuleList = _modules;
                
                var splitedId:Array = _storageId.split(".");
                if (splitedId.length == 1) return;
                splitedId[splitedId.length-1] = idSuffix;
                
                StorageAccessor.overwriteModuleList(
                    _storageId, _pathParser.elementId,
                    elementId, _storageId = splitedId.join("."),
                    _modules);
            }
            
            _pathParser.initialize(layerId, viewId, elementId);
            _modules = StorageAccessor.requestModule(_storageId, _pathParser.elementId);
            Log.custom(TAG, "initialized",　this);
            /*
            Log.custom(TAG, "hasBeforeModuleList", Boolean(b), "equalReference", _modules === b);
            if (b && _modules !== b)
            {
                b.dump();
                _modules.dump();
            }
            */
        }
        
        public function get path():ElementPathParser
        {
            return _pathParser;
        }
        
        public function get storageId():String
        {
            return _storageId;
        }
        
        public function toString():String
        {
            return _pathParser.toString()
                + " storageId:" + _storageId;
        }
    }
}