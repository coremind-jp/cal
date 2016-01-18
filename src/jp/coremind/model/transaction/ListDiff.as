package jp.coremind.model.transaction
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    /**
     * データ構造に配列を採用しているデータのトランザクションを処理するクラス.
     */
    public class ListDiff extends HashDiff
    {
        private static const EMPTY:Dictionary = new Dictionary(true);
        
        private var
            _moved:Vector.<TransactionLog>,
            _order:Vector.<int>,
            _filtered:Dictionary,
            _filteredIndexList:Vector.<int>,
            _restored:Dictionary;
        
        public function ListDiff() {}
        
        /**
         * 元データと比較してフィルタリングされたデータのリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        //public function get filtered():Array
        public function get filtered():Dictionary
        {
            return _filtered ? _filtered: _filtered = new Dictionary(true);
        }
        
        public function get filteredIndexList():Vector.<int>
        {
            return _filteredIndexList ? _filteredIndexList: _filteredIndexList = new <int>[];
        }
        
        /**
         * 元データと比較してフィルタリングが解除されたデータのリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        public function get filteringRestored():Dictionary
        {
            return _restored ? _restored: _restored = new Dictionary(true);
        }
        
        /**
         * 元データにソート関数を実行した結果(ソート後のindex配列)を返す.
         */
        public function get order():Vector.<int>
        {
            return _order;
        }
        
        /**
         * 元データと比較して削除されたデータを保持するTransactionLogリストを返す.
         * このリストはbuildメソッド呼出し後に更新される。
         */
        public function get moved():Vector.<TransactionLog>
        {
            return _moved ? _moved: _moved = new <TransactionLog>[];
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
            latestFilteringList:Dictionary = null):void
        {
            if (latestFilteringList === null)
                latestFilteringList = EMPTY;
            
            _editedOrigin = (origin as Array).slice();
            
            for (var i:int = 0; i < history.length; i++)
                _applyTransactionLog(history[i]);
            
            for (var j:int = removed.length - 1; 0 <= j; j--) 
                _editedOrigin.splice(removed[j].index, 1);
            
            //applySort
            _createOrder(_editedOrigin, sortNames, sortOptions);
            
            //直前のフィルタリングリストはフィルタ解除リストに役割を変える
            if (filter is Function) _applyFilter(filter, latestFilteringList);
            _restored = latestFilteringList;
        }
        
        /**
         * 元データにフィルタ関数を適応し必要なデータだけを抽出する.
         * 同時に直前に実行されたフィルタリング差分を割り出す。
         */
        protected function _applyFilter(f:Function, latestFilteringList:Dictionary):void
        {
            var len:int = _editedOrigin.length;
            if (len == 0) return;
            
            //create instance
            filtered;
            
            //sort & filter order
            var newOrder:Vector.<int> = new Vector.<int>();
            
            var i:int, data:*;
            if (_order)
            {
                for (i = 0; i < len; i++) 
                {
                    var n:int = _order[i];
                    data = _editedOrigin[n];
                    
                    if (f(data))
                    {
                        _filtered[data] = true;
                        delete latestFilteringList[data];
                    }
                    else
                    {
                        newOrder[newOrder.length] = n;
                    }
                }
                
                //clear sort order.
                _order.length = 0;
            }
            else
            {
                for (i = 0; i < len; i++) 
                {
                    data = _editedOrigin[i];
                    
                    if (f(data))
                    {
                        _filtered[data] = true;
                        delete latestFilteringList[data];
                    }
                    else
                    {
                        newOrder[newOrder.length] = i;
                    }
                }
            }
            
            _order = newOrder;
        }
        
        /**
         * 元データにソート関数を適応し並び順を更新(orderVector配列)を更新する.
         */
        private function _createOrder(list:Array, names:*, options:* = 0):void
        {
            if (names !== null)
            {
                if ((options  & Array.RETURNINDEXEDARRAY) == 0)
                     options |= Array.RETURNINDEXEDARRAY;
                
                _order = Vector.<int>(list.sortOn(names, options));
            }
            else _order = null;
        }
        
        override protected function _applyTransactionLog(log:TransactionLog):void
        {
            Log.info("applyTransactionLog", log);
            
            if (log.updated())
            {
                updated.push(log);
                
                _editedOrigin[log.index] = log.value;
            }
            else
            if (log.added())
            {
                if (log.index == -1)
                {
                    //_key設定の為、key指定をして呼び出し直し
                    log.add(_editedOrigin.length);
                    
                    _editedOrigin.push(log.value);
                }
                else
                    _editedOrigin.splice(log.index, 0, log.value);
                    
                added.push(log);
            }
            else
            if (log.removed())
            {
                //_key設定の為、key指定をして呼び出し直し
                log.remove(_editedOrigin.indexOf(log.value));
                
                if (log.index > -1)
                {
                    removed.push(log);
                    //spliceは全てのログのindexを割り出してから一括で行う
                }
            }
            else
            if (log.swapped())
            {
                var swapFrom:int = _editedOrigin.indexOf(log.value);
                var swapTo:int   = _editedOrigin.indexOf(log.swapKey);
                if (swapFrom > -1 && swapTo > -1)
                {
                    var tmp:* = _editedOrigin[swapTo];
                    _editedOrigin[swapTo]   = _editedOrigin[swapFrom];
                    _editedOrigin[swapFrom] = tmp;
                    
                    swapped.push(log);
                }
                else
                {
                    if (swapFrom == -1) Log.warning("[Transaction::swap] undefined value(from)", log.value);
                    if (  swapTo == -1) Log.warning("[Transaction::swap] undefined value(to)", log.key);
                }
            }
            else
            if (log.moved())
            {
                var moveFrom:int = _editedOrigin.indexOf(log.value);
                var moveTo:int   = _editedOrigin.indexOf(log.swapKey);
                
                if (moveFrom > -1 && moveTo > -1)
                {
                    _editedOrigin.splice(moveFrom, 1);
                    _editedOrigin.splice(moveTo, 0, log.value);
                    Log.info("[ContainerDiff] from", moveFrom, "to", moveTo);
                    
                    moved.push(log);
                }
                else
                {
                    if (moveFrom == -1) Log.warning("[Transaction::move] undefined value(from)", log.value);
                    if (  moveTo == -1) Log.warning("[Transaction::move] undefined value(to)", log.key);
                }
            }
        }
    }
}