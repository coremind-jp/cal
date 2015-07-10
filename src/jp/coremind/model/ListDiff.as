package jp.coremind.model
{
    /**
     * データ構造に配列を採用しているデータのトランザクションを処理するクラス.
     */
    public class ListDiff extends HashDiff
    {
        private var _order:Vector.<int>;
        
        public function ListDiff() {}
        
        /**
         * 元データにソート関数を実行した結果(ソート後のindex配列)を返す.
         */
        public function get order():Vector.<int>
        {
            return _order;
        }
        
        /**
         * 元データと比較し差分データを作成する.
         * このメソッドの呼び出し後にeditedOrigin, updated, added, moved, filtered, orderアクセサにアクセスすることができる。
         */
        override public function build(
            origin:*,
            history:Vector.<TransactionLog>,
            sortNames:* = null,
            sortOptions:* = 0,
            filter:Function = null,
            latestFilteringList:Array = null):void
        {
            _editedOrigin = (origin as Array).slice();
            
            for (var i:int = 0; i < history.length; i++)
                _applyTransactionLog(history[i]);
            
            //applyFilter
            if (filter is Function)
                _applyFilter(filter, latestFilteringList);
            
            //直前のフィルタリングリストはフィルタ解除リストに役割を変える
            _restored = latestFilteringList;
            
            //applySort
            _createOrder(_editedOrigin, sortNames, sortOptions);
        }
        
        override protected function _applyFilter(f:Function, latestFilteringList:Array):void
        {
            for (var i:int = 0, len:int = _editedOrigin.length; i < len; i++) 
            {
                if (f(_editedOrigin[i])) continue;
                
                var data:* = _editedOrigin.splice(i, 1)[0];
                i--; len--;
                
                filtered.push(data);
                
                var n:int =  latestFilteringList.indexOf(data);
                if (n != -1) latestFilteringList.splice(n, 1);
            }
        }
        
        /**
         * 元データにソート関数を適応し並び順を更新(orderVector配列)を更新する.
         */
        private function _createOrder(list:Array, names:*, options:* = 0):void
        {
            if (names === null)
            {
                _order = new <int>[];
                
                for (var i:int = 0, len:int = list.length; i < len; i++)
                    _order[i] = i;
            }
            else
            {
                if ((options  & Array.RETURNINDEXEDARRAY) == 0)
                     options |= Array.RETURNINDEXEDARRAY;
                
                _order = Vector.<int>(list.sortOn(names, options));
            }
        }
        
        override protected function _applyTransactionLog(log:TransactionLog):void
        {
            if (log.updated())
            {
                updated.push(log);
                
                _editedOrigin[log.index] = log.value;
            }
            else
            if (log.added())
            {
                //_key設定の為、key指定をして呼び出し直し
                log.add(_editedOrigin.length);
                
                added.push(log);
                _editedOrigin.push(log.value);
            }
            else
            if (log.removed())
            {
                //_key設定の為、key指定をして呼び出し直し
                log.remove(_editedOrigin.indexOf(log.value));
                
                if (log.index > -1)
                {
                    removed.push(log);
                    _editedOrigin.splice(log.index, 1);
                }
            }
        }
    }
}