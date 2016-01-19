package jp.coremind.storage.transaction
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    public class ListTransaction extends Transaction
    {
        private static const EMPTY:Dictionary = new Dictionary(true);
        
        private var
            _filter:Function,
            _sortNames:*,
            _sortOptions:int,
            _latestFiltered:Dictionary;
        
        public function ListTransaction()
        {
        }
        
        public function filter(f:Function):Boolean
        {
            if (_filter === f)
                return false;
            else
            {
                _filter = f;
                return true;
            }
        }
        
        public function sortOn(names:*, options:* = 0):Boolean
        {
            if (_sortNames === names && _sortOptions === options)
                return false;
            else
            {
                _sortNames   = names;
                _sortOptions = options;
                return true;
            }
        }
        
        override public function rollback():void
        {
            super.rollback();
            _filter    = null;
            _sortNames = null;
            _latestFiltered = null;
        }
        
        public function add(valueFrom:*, valueTo:* = null):ListTransaction
        {
            _history.push(new ListAdd(valueFrom).setToData(valueTo));
            _position++;
            
            return this;
        }
        
        public function remove(valueFrom:*):ListTransaction
        {
            _history.push(new ListRemove(valueFrom));
            _position++;
            
            return this;
        }
        
        public function swap(valueFrom:*, valueTo:*):ListTransaction
        {
            _history.push(new ListSwap(valueFrom).setToData(valueTo));
            _position++;
            
            return this;
        }
        
        public function move(valueFrom:*, valueTo:*):ListTransaction
        {
            _history.push(new ListMove(valueFrom).setToData(valueTo));
            _position++;
            
            return this;
        }
        
        override public function apply(origin:*):Diff
        {
            var clonedList:Array  = origin.slice();
            var info:DiffListInfo = new DiffListInfo();
            var diff:Diff         = new Diff(clonedList, info, null);
            
            for (var i:int = 0; i < _position; i++)
            {
                Log.info(i, _history[i]);
                _history[i].apply(diff);
            }
            
            _applyFilter(clonedList, info, _createSortOrder(clonedList, info));
            
            Log.info(info);
            
            return diff;
        }
        
        /**
         * 元データにソート関数を適応し並び順を更新(orderVector配列)を更新する.
         */
        private function _createSortOrder(list:Array, info:DiffListInfo):Vector.<int>
        {
            if (!_sortNames) return null;
            
            if ((_sortOptions  & Array.RETURNINDEXEDARRAY) == 0)
                 _sortOptions |= Array.RETURNINDEXEDARRAY;
            
            return Vector.<int>(list.sortOn(_sortNames, _sortOptions));
        }
        
        /**
         * 元データにフィルタ関数を適応し必要なデータだけを抽出する.
         * 同時に直前に実行されたフィルタリング差分を割り出す。
         */
        protected function _applyFilter(list:Array, info:DiffListInfo, sortOrder:Vector.<int>):void
        {
            var len:int = list.length;
            if (_filter === null || len == 0)
            {
                info.setOrder(sortOrder);
                return;
            }
            
            if (_latestFiltered === null)
                _latestFiltered = EMPTY;
            
            var filtered:Dictionary = new Dictionary(true);
            
            //sort & filter order
            var filterOrder:Vector.<int> = new <int>[];
            
            var i:int, data:*;
            if (sortOrder)
            {
                for (i = 0; i < len; i++) 
                {
                    var n:int = sortOrder[i];
                    data = list[n];
                    
                    if (_filter(data))
                    {
                        filtered[data] = true;
                        delete _latestFiltered[data];
                    }
                    else filterOrder[filterOrder.length] = n;
                }
                sortOrder.length = 0;//clear old order.
            }
            else
            {
                for (i = 0; i < len; i++) 
                {
                    data = list[i];
                    
                    if (_filter(data))
                    {
                        filtered[data] = true;
                        delete _latestFiltered[data];
                    }
                    else filterOrder[filterOrder.length] = i;
                }
            }
            
            info.setOrder(filterOrder);
            info.setFilteringRestored(_latestFiltered);
            info.setFiltered(filtered);
            _latestFiltered = info.filtered;//直前のフィルタリングリストはフィルタ解除リストに役割を変える
        }
    }
}