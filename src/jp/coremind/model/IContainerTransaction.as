package jp.coremind.model
{
    public interface IContainerTransaction extends ITransaction
    {
        function createValue(value:*, key:*):void;
        function deleteValue(value:*):void;
    }
}