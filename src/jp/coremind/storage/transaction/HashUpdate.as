package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class HashUpdate implements ITransactionLog
    {
        private var
            _value:*,
            _key:*;
        
        /**
         * keyパラメータキーに紐づいているデータをvalueパラメータに更新する。キーが存在しない場合、何もしない.
         */
        public function HashUpdate(value:*, key:*)
        {
            _value = value;
            _key = key;
        }
        
        public function apply(diff:Diff):void
        {
            var hash:Object = diff.transactionResult as Object;
            
            if (_key in hash)
            {
                hash[_key] = _value;
                diff.hashInfo.edited.push(_key);
            }
            else Log.warning("[Transaction::HashUpdate] undefined key", _key);
        }
    }
}