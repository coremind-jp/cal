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
            _filterRestored:Dictionary,
            _removeRestored:Dictionary;
        
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
            _filterRestored = null;
        }
        
        public function add(value:*, indexValue:* = null):ListTransaction
        {
            pushLog(new ListAdd(value, indexValue));
            return this;
        }
        
        public function remove(removeValue:*):ListTransaction
        {
            pushLog(new ListRemove(removeValue));
            return this;
        }
        
        public function swap(fromIndexValue:*, toIndexValue:*):ListTransaction
        {
            pushLog(new ListSwap(fromIndexValue, toIndexValue));
            return this;
        }
        
        public function move(fromIndexValue:*, toIndexValue:*):ListTransaction
        {
            pushLog(new ListMove(fromIndexValue, toIndexValue));
            return this;
        }
        
        override public function apply(origin:*):Diff
        {
            var clonedList:Array   = origin.slice();
            var info:DiffListInfo  = new DiffListInfo();
            var diff:Diff          = new Diff(clonedList, info, null);
            var removed:Dictionary = new Dictionary(true);
            
            info.setRemoved(removed);
            
            for (var i:int = 0; i < _position; i++)
                _history[i].apply(diff);
            
            if (_removeRestored !== null)
                for (var removedData:* in removed)
                    if (removedData in _removeRestored)
                        delete _removeRestored[removedData];
            
            info.setRemoveRestored(_removeRestored);
            _removeRestored = removed;
            
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
            
            var option:int = (_sortOptions & Array.RETURNINDEXEDARRAY) == 0 ?
                _sortOptions |= Array.RETURNINDEXEDARRAY:
                _sortOptions;
            
            return Vector.<int>(list.sortOn(_sortNames, option));
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
                _filterRestored = null;
                info.setOrder(sortOrder);
                return;
            }
            
            if (_filterRestored === null)
                _filterRestored = EMPTY;
            
            var filtered:Dictionary = new Dictionary(true);
            
            //filter(include sort) order
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
                        delete _filterRestored[data];
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
                        delete _filterRestored[data];
                    }
                    else filterOrder[filterOrder.length] = i;
                }
            }
            
            info.setOrder(filterOrder);
            info.setFilterRestored(_filterRestored);
            info.setFiltered(filtered);
            _filterRestored = info.filtered;//直前のフィルタリングリストはフィルタ解除リストに役割を変える
        }
    }
}