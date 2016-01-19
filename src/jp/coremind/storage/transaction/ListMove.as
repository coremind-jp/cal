package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class ListMove extends TransactionLog implements ITransactionLog
    {
        /**
         *　toData(setToDataメソッドの呼び出し)必須.
         * 配列のfromDataをtoDataのインデックスへ移動する.
         * fromData, toDataどちらかの参照が見つからない場合、何もしない。
         */
        public function ListMove(fromData:*)
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
                Log.info("[Transaction::ListMove]", fromData, "(", fromIndex, ") =>", toData, "(", toIndex, ")");
                list.splice(fromIndex, 1);
                list.splice(toIndex, 0, fromData);
            }
            else
            {
                if (fromIndex == -1) Log.warning("[Transaction::ListMove] undefined value(from)", fromData);
                if (  toIndex == -1) Log.warning("[Transaction::ListMove] undefined value(to)", toData);
            }
        }
    }
}