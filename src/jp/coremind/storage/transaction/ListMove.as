package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class ListMove implements ITransactionLog
    {
        private var
            _fromIndexValue:*,
            _toIndexValue:*;
        
        /**
         * toIndexValueパラメータと同一参照のデータのインデックス位置にfromIndexValueパラメータを移動する.
         * どちらかの参照が存在しない場合、何もしない。
         */
        public function ListMove(fromIndexValue:*, toIndexValue:*)
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
                Log.info("[Transaction::ListMove]", _fromIndexValue, "(", fromIndex, ") =>", _toIndexValue, "(", toIndex, ")");
                list.splice(fromIndex, 1);
                list.splice(toIndex, 0, _fromIndexValue);
            }
            else
            {
                if (fromIndex == -1) Log.warning("[Transaction::ListMove] undefined value(from)", _fromIndexValue);
                if (  toIndex == -1) Log.warning("[Transaction::ListMove] undefined value(to)", _toIndexValue);
            }
        }
    }
}