package jp.coremind.model.transaction
{
    import jp.coremind.utility.Log;

    public class HashUpdate extends TransactionLog implements ITransactionLog
    {
        /**
         * toData(String型のみ)をキーとする値をfromDataへ書き換える。
         * toDataがキーとして存在しない場合、何もしない。
         */
        public function HashUpdate(fromData:*)
        {
            super(fromData);
        }
        
        public function apply(diff:Diff):void
        {
            var hash:Object = diff.editedOrigin as Object;
            
            if (toData in hash)
            {
                hash[toData] = fromData;
                diff.hashInfo.edited.push(toData);
            }
            else Log.warning("[Transaction::HashUpdate] undefined key", toData);
        }
    }
}