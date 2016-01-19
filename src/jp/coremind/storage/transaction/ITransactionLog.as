package jp.coremind.storage.transaction
{
    public interface ITransactionLog
    {
        function apply(diff:Diff):void;
    }
}