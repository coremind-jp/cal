package jp.coremind.model.transaction
{
    import jp.coremind.utility.Log;

    public class HashAdd extends TransactionLog implements ITransactionLog
    {
        /**
         * toData(String型のみ)をキーとしてfromDataを追加する。
         * 既にtoDataがキーとして存在する場合、何もしない。
         */
        public function HashAdd(fromData:*)
        {
            super(fromData);
        }
        
        public function apply(diff:Diff):void
        {
            var hash:Object = diff.editedOrigin as Object;
            
            if (toData in hash)
                Log.warning("[Transaction::HashAdd] already defined key", toData);
            else
            {
                hash[toData] = fromData;
                diff.hashInfo.edited.push(toData);
            }
        }
    }
}