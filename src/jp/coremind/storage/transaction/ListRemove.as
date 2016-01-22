package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class ListRemove implements ITransactionLog
    {
        private var _removeValue:*;
        
        /**
         * removeValueパラメータと同一参照のデータのインデックス位置のデータを取り除く。同一参照が存在しない場合、何もしない.
         */
        public function ListRemove(removeValue:*)
        {
            _removeValue = removeValue;
        }
        
        public function apply(diff:Diff):void
        {
            var list:Array = diff.transactionResult as Array;
            var removeIndex:int = list.indexOf(_removeValue);
            
            if (removeIndex > -1)
            {
                list.splice(removeIndex, 1);
                diff.listInfo.removed[_removeValue] = removeIndex;
            }
            else Log.warning("[Transaction::ListRemove] undefined value", _removeValue);
        }
    }
}