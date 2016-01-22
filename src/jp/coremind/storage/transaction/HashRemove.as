package jp.coremind.storage.transaction
{
    public class HashRemove implements ITransactionLog
    {
        private var _removeValue:*;
        
        /**
         * removeValueパラメータと同一参照のデータを取り除く。
         */
        public function HashRemove(removeValue:*)
        {
            _removeValue = removeValue;
        }
        
        public function apply(diff:Diff):void
        {
            var hash:Object = diff.transactionResult as Object;
            
            if (_removeValue in hash)
            {
                delete hash[_removeValue];
                diff.hashInfo.edited.push(_removeValue);
            }
        }
    }
}