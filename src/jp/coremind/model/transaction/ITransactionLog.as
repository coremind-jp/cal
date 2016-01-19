package jp.coremind.model.transaction
{
    public interface ITransactionLog
    {
        function apply(diff:Diff):void;
    }
}