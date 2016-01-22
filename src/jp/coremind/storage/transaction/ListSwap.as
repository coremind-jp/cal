package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class ListSwap implements ITransactionLog
    {
        private var
            _fromIndexValue:*,
            _toIndexValue:*;
        
        /**
         * toIndexValueパラメータと同一参照のデータのインデックス位置と
         * fromIndexValueパラメータと同一参照のデータのインデックス位置を入れ替える.
         * どちらかの参照が存在しない場合、何もしない。
         */
        public function ListSwap(fromIndexValue:*, toIndexValue:*)
        {
            _fromIndexValue = fromIndexValue;
            _toIndexValue = toIndexValue;
        }
        
        public function apply(diff:Diff):void
        {
            var list:Array = diff.transactionResult as Array;
            var fromIndex:int = list.indexOf(_fromIndexValue);
            var   toIndex:int = list.indexOf(_toIndexValue);
            
            if (fromIndex > -1 && toIndex > -1)
            {
                var tmp:* = list[toIndex];
                list[toIndex]   = list[fromIndex];
                list[fromIndex] = tmp;
            }
            else
            {
                if (fromIndex == -1) Log.warning("[Transaction::ListSwap] undefined value(from)", _fromIndexValue);
                if (  toIndex == -1) Log.warning("[Transaction::ListSwap] undefined value(to)", _toIndexValue);
            }
        }
    }
}