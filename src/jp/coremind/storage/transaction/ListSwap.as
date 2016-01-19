package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class ListSwap extends TransactionLog implements ITransactionLog
    {
        /**
         *　toData(setToDataメソッドの呼び出し)必須.
         * 配列のfromData, toDataのインデックスを入れ替える.
         * fromData, toDataどちらかの参照が見つからない場合、何もしない。
         */
        public function ListSwap(fromData:*)
        {
            super(fromData);
        }
        
        public function apply(diff:Diff):void
        {
            var list:Array = diff.editedOrigin as Array;
            var fromIndex:int = list.indexOf(fromData);
            var   toIndex:int = list.indexOf(toData);
            
            if (fromIndex > -1 && toIndex > -1)
            {
                var tmp:* = list[toIndex];
                list[toIndex]   = list[fromIndex];
                list[fromIndex] = tmp;
            }
            else
            {
                if (fromIndex == -1) Log.warning("[Transaction::ListSwap] undefined value(from)", fromData);
                if (  toIndex == -1) Log.warning("[Transaction::ListSwap] undefined value(to)", toData);
            }
        }
    }
}