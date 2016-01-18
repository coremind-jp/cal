package jp.coremind.storage
{
    import jp.coremind.model.transaction.Diff;

    public interface IModelStorageListener
    {
        /**
         * トランザクション実行中にデータに変化があった場合のハンドリングメソッド.
         * @params  plainDiff   オリジナルデータとの差分を表すDiffインスタンス
         */
        function preview(plainDiff:Diff):void
            
        /**
         * データ変更が確定した場合のハンドリングメソッド.
         * @params  plainDiff   オリジナルデータとの差分を表すDiffインスタンス
         */
        function commit(plainDiff:Diff):void
    }
}