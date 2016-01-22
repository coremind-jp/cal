package jp.coremind.storage.transaction
{
    public class ListAdd implements ITransactionLog
    {
        private var
            _value:*,
            _indexValue:*;
        
        /**
         * indexValueパラメータと同一参照のデータのインデックス位置にvalueパラメータを追加する.
         * 同一参照が存在しない場合、配列末尾に追加する。
         */
        public function ListAdd(value:*, indexValue:*)
        {
            _value = value;
            _indexValue = indexValue;
        }
        
        public function apply(diff:Diff):void
        {
            var list:Array = diff.transactionResult as Array;
            var toIndex:int = list.indexOf(_indexValue);
            
            list.splice(toIndex == -1 ? list.length: toIndex, 0, _value);
        }
    }
}