package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class ListRemove extends TransactionLog implements ITransactionLog
    {
        /**
         * 配列を走査しfromDataと同一参照だったインデックスを配列から取り除く.
         * 配列に同一参照が見つからない場合、何もしない。
         */
        public function ListRemove(fromData:*)
        {
            super(fromData);
        }
        
        public function apply(diff:Diff):void
        {
            var list:Array = diff.editedOrigin as Array;
            var fromIndex:int = list.indexOf(fromData);
            
            if (fromIndex > -1)
            {
                list.splice(fromIndex, 1);
                diff.listInfo.removed[fromData] = fromIndex;
            }
            else Log.warning("[Transaction::ListRemove] undefined value", fromData);
        }
    }
}