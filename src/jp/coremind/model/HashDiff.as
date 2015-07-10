package jp.coremind.model
{
    import jp.coremind.utility.Log;
    
    /**
     * データ構造にハッシュ配列を採用しているデータのトランザクションを処理するクラス.
     */
    public class HashDiff extends Diff
    {
        protected var
            _added:Vector.<TransactionLog>,
            _removed:Vector.<TransactionLog>,
            _filtered:Array,
            _restored:Array;
        
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
         * 元データと比較してフィルタリングされたデータのリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        public function get filtered():Array
        {
            return _filtered ? _filtered: _filtered = [];
        }
        
        /**
         * 元データと比較してフィルタリングが解除されたデータのリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        public function get filteringRestored():Array
        {
            return _restored ? _restored: _restored = [];
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
            latestFilteringList:Array = null):void
        {
            _editedOrigin = $.hash.keyClone(origin);
            
            for (var i:int = 0; i < history.length; i++)
                _applyTransactionLog(history[i]);
            
            //applyFilter
            if (filter is Function)
                _applyFilter(filter, latestFilteringList);
            
            //直前のフィルタリングリストはフィルタ解除リストに役割を変える
            _restored = latestFilteringList;
        }
        
        /**
         * 元データにフィルタ関数を適応し必要なデータだけを抽出する.
         * 同時に直前に実行されたフィルタリング差分を割り出す。
         */
        protected function _applyFilter(f:Function, latestFilteringList:Array):void
        {
            for (var p:* in _editedOrigin) 
            {
                if (f(_editedOrigin[p])) continue;
                
                var data:* = _editedOrigin[p];
                delete _editedOrigin[p];
                
                filtered.push(data);
                
                var n:int =  latestFilteringList.indexOf(data);
                if (n != -1) latestFilteringList.splice(n, 1);
            }
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
        }
    }
}