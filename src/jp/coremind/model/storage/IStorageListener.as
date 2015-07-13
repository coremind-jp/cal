package jp.coremind.model.storage
{
    import jp.coremind.model.Diff;

    public interface IStorageListener
    {
        function preview(plainDiff:Diff):void
        function commit(plainDiff:Diff):void
    }
}