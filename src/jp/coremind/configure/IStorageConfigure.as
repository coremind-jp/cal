package jp.coremind.configure
{
    public interface IStorageConfigure
    {
        function getExtendProperty(key:String):*
        function setExtendProperty(key:String, value:*):void
        
        function getStorageType(storageId:String):String;
        function createInitialValue(storageId:String):*;
    }
}