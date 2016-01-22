package jp.coremind.storage.transaction
{
    import jp.coremind.utility.Log;

    public class HashAdd implements ITransactionLog
    {
        private var
            _value:*,
            _key:*;
        
        /**
         * keyパラメータをキーにvalueパラメータを追加する。既にキーが存在する場合、何もしない.
         */
        public function HashAdd(value:*, key:String)
        {
            _value = value;
            _key = key;
        }
        
        public function apply(diff:Diff):void
        {
            var hash:Object = diff.transactionResult as Object;
            
            if (_key in hash)
                Log.warning("[Transaction::HashAdd] already defined key", _key);
            else
            {
                hash[_key] = _value;
                diff.hashInfo.edited.push(_value);
            }
        }
    }
}