package jp.coremind.model.transaction
{
    /**
     * データ構造にプリミティブ型を採用しているデータのトランザクションを処理するクラス.
     */
    public class Diff
    {
        protected var
            _editedOrigin:*,
            _updated:Vector.<TransactionLog>;
        
        public function Diff() {}
        
        /**
         * 元データにトランザクションに含まれる差分を適応したデータを返す.
         */
        public function get editedOrigin():*
        {
            return _editedOrigin;
        }
        
        /**
         * 元データと比較して変更が発生したデータを保持するTransactionLogリストを返す.
         */
        public function get updated():Vector.<TransactionLog>
        {
            return _updated ? _updated: _updated = new <TransactionLog>[];
        }
        
        public function createUpdatedKeyList():Array
        {
            var result:Array = [];
            
            for (var i:int = 0, len:int = updated.length; i < len; i++) 
                result[i] = updated[i].key;
            
            return result;
        }
        
        /**
         * 元データと比較し差分データを作成する.
         * このメソッドの呼び出し後にeditedOrigin, updatedアクセサにアクセスすることができる。
         */
        public function build(
            origin:*,
            history:Vector.<TransactionLog>,
            sortNames:* = null,
            sortOptions:* = 0,
            filter:Function = null,
            latestFilteringList:Array = null):void
        {
            for (var i:int = 0; i < history.length; i++)
                _applyTransactionLog(history[i]);
        }
        
        /**
         * 元データにデータ操作差分(TransactionLog)を適応する.
         */
        protected function _applyTransactionLog(log:TransactionLog):void
        {
            if (log.updated())
            {
                updated.push(log);
                
                log.key === null ?
                    _editedOrigin = log.value:
                    _editedOrigin[log.key] = log.value;
            }
        }
    }
}