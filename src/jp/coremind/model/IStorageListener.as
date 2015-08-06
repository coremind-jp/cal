package jp.coremind.model
{
    public interface IStorageListener
    {
        function preview(plainDiff:Diff):void
        function commit(plainDiff:Diff):void
    }
}