package jp.coremind.model.transaction
{
    public class HashRemove extends TransactionLog implements ITransactionLog
    {
        /**
         * fromData(String型のみ)をキーとするデータを取り除く。
         */
        public function HashRemove(fromData:*)
        {
            super(fromData);
        }
        
        public function apply(diff:Diff):void
        {
            var hash:Object = diff.editedOrigin as Object;
            
            if (fromData in hash)
            {
                delete hash[fromData];
                diff.hashInfo.edited.push(fromData);
            }
        }
    }
}