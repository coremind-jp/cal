package jp.coremind.model
{
    public class StorageConfigure
    {
        private var
            _elementName:String,
            _storageId:String,
            _storageType:String,
            _initialValue:*;
        
        public function StorageConfigure(elementName:String, storageId:String, initialValue:* = null, storageType:String = StorageType.HASH)
        {
            _elementName  = elementName;
            _storageId    = storageId;
            _initialValue = initialValue || {};
            _storageType  = storageType;
        }
        
        public function get elementName():String
        {
            return _elementName;
        }

        public function get storageId():String
        {
            return _storageId;
        }
        
        public function get storageType():String
        {
            return _storageType;
        }

        public function getInitialValue():*
        {
            return _initialValue is Function ? _initialValue(): _initialValue;
        }
    }
}