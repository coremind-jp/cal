package jp.coremind.event
{
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.model.ElementModel;
    import jp.coremind.storage.Storage;
    import jp.coremind.storage.StorageModelReader;
    import jp.coremind.utility.Log;

    public class ElementInfo
    {
        private var
            _ownerLayerId:String,
            _ownerViewId:String,
            _elementId:String,
            _storageId:String;
        
        public function ElementInfo(ownerLayerId:String, ownerViewId:String, elementId:String, storageId:String)
        {
            _ownerLayerId = ownerLayerId;
            _ownerViewId  = ownerViewId;
            _elementId    = elementId;
            _storageId    = storageId;
        }
        
        public function get reader():StorageModelReader
        {
            if (_storageId)
                return StorageAccessor.requestModelReader(_storageId);
            else
            {
                Log.info("undefined storageId", this);
                return StorageAccessor.requestModelReader(Storage.UNDEFINED_STORAGE_ID);
            }
        }
        
        public function get elementModel():ElementModel
        {
            return StorageAccessor.requestElementModel(_storageId, _elementId);
        }
        
        public function get elementId():String
        {
            return _elementId;
        }
        
        public function createRouterKey(statusGroup:String, statusValue:String):String
        {
            return _ownerViewId+_elementId+statusGroup+statusValue;
        }
        
        public function toString():String
        {
            return "ownerLayerId:" + _ownerLayerId
                + " ownerViewId:"  + _ownerViewId
                + " elementId:"    + _elementId
                + " storageId:"    + _storageId;
        }
    }
}