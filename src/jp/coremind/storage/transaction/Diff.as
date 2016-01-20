package jp.coremind.storage.transaction
{
    public class Diff
    {
        private var
            _transactionResult:*,
            _listInfo:DiffListInfo,
            _hashInfo:DiffHashInfo;
        
        public function Diff(
            v:*,
            listInfo:DiffListInfo,
            hashInfo:DiffHashInfo)
        {
            _transactionResult = v;
            _listInfo = listInfo;
            _hashInfo = hashInfo;
        }
        
        /**
         * 元データにトランザクションに含まれる差分を適応したデータを返す.
         */
        internal function get transactionResult():* { return _transactionResult; }
        
        /**
         * このオブジェクトで保持しているtransactionResultの参照を削除し、保持していた値を返す.
         */
        public function deleteTransactionResult():*
        {
            var result:* = _transactionResult;
            
            _transactionResult = null;
            
            return result;
        }
        
        public function get listInfo():DiffListInfo { return _listInfo; }
        
        public function get hashInfo():DiffHashInfo { return _hashInfo; }
    }
}