package jp.coremind.model.transaction
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;
    
    /**
     * データ構造にハッシュ配列を採用しているデータのトランザクションを処理するクラス.
     */
    public class HashDiff extends Diff
    {
        protected var
            _added:Vector.<TransactionLog>,
            _removed:Vector.<TransactionLog>,
            _swapped:Vector.<TransactionLog>;
        
        public function HashDiff() {}
        
        /**
         * 元データと比較して新規に追加されたデータを保持するTransactionLogリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        public function get added():Vector.<TransactionLog>
        {
            return _added ? _added: _added = new <TransactionLog>[];
        }
        
        /**
         * 元データと比較して削除されたデータを保持するTransactionLogリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        public function get removed():Vector.<TransactionLog>
        {
            return _removed ? _removed: _removed = new <TransactionLog>[];
        }
        
        /**
         * 元データと比較して削除されたデータを保持するTransactionLogリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        public function get swapped():Vector.<TransactionLog>
        {
            return _swapped ? _swapped: _swapped = new <TransactionLog>[];
        }
        
        /**
         * 元データと比較し差分データを作成する.
         * このメソッドの呼び出し後にeditedOrigin, updated, added, moved, filteredアクセサにアクセスすることができる。
         */
        override public function build(
            origin:*,
            history:Vector.<TransactionLog>,
            sortNames:* = null,
            sortOptions:* = 0,
            filter:Function = null,
            latestFilteringList:Dictionary = null):void
        {
            _editedOrigin = $.hash.keyClone(origin);
            
            for (var i:int = 0; i < history.length; i++)
                _applyTransactionLog(history[i]);
        }
        
        override protected function _applyTransactionLog(log:TransactionLog):void
        {
            if (log.updated())
            {
                if (!(log.key in _editedOrigin))
                    Log.warning("[ContainerDiff::createEditedOrigin] undefined key("+log.key+")");
                
                updated.push(log);
                _editedOrigin[log.key] = log.value;
            }
            else
            if (log.added())
            {
                if (log.key in _editedOrigin)
                    Log.warning("[ContainerDiff::createEditedOrigin] already defined key("+log.key+")");
                
                added.push(log);
                _editedOrigin[log.key] = log.value;
            }
            else
            if (log.removed())
            {
                removed.push(log);
                delete _editedOrigin[log.key];
            }
            else
            if (log.swapped())
            {
                var fromKey:String = $.hash.findKey(_editedOrigin, log.value);
                var toKey:String   = $.hash.findKey(_editedOrigin, log.swapKey);
                if (fromKey && toKey)
                {
                    var tmp:* = _editedOrigin[toKey];
                    _editedOrigin[toKey]   = _editedOrigin[fromKey];
                    _editedOrigin[fromKey] = tmp;
                    
                    swapped.push(log);
                }
                else
                {
                    if (!fromKey) Log.warning("[ContainerDiff::createEditedOrigin] undefined value(from)", log.value);
                    if (  !toKey) Log.warning("[ContainerDiff::createEditedOrigin] undefined value(to)"  , log.swapKey);
                }
            }
        }
    }
}