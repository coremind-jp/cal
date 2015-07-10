package jp.coremind.model
{
    import jp.coremind.utility.Log;

    public class ListTransaction /*implements ITransaction*/
    {
        /*
        private static const SKIP_SORT:Function = function(list:Array):Array { return list; };
        private static const SKIP_FILTER:Function = SKIP_SORT;
        
        private var
            _filter:Function,
            _sort:Function,
            _visualize:Boolean,
            _history:Vector.<TransactionLog>,
            _list:IList;
        
        public function ListTransaction(observer:IList)
        {
            _filter = SKIP_FILTER;
            _sort = SKIP_SORT;
            _visualize = false;
            _list = observer;
        }
        
        public function destroy():void
        {
            _filter = SKIP_FILTER;
            _sort = SKIP_SORT;
            
            if (_history)
                _history.length = 0;
            _history = null;
            
            _list = null;
        }
        
        public function isRunning():Boolean { return Boolean(_history); }
        
        public function begin(visualize:Boolean = true):ListTransaction
        {
            if (!isRunning())
            {
                _visualize = visualize;
                _history = new Vector.<TransactionLog>();
            }
            return this;
        }
        
        public function createValue(value:*, key:*):void
        {
            var i:int = _list.originRef.indexOf(value);
            if (i == -1) _dispatch(new TransactionLog(value).add());
        }
        
        public function deleteValue(value:*):void
        {
            var i:int = _list.originRef.indexOf(value);
            if (i > -1) _dispatch(new TransactionLog(value).remove());
        }
        
        private function _dispatch(log:TransactionLog):void
        {
            if (isRunning())
            {
                _history.push(log);
                
                if (_visualize)
                    _list.preview(createDiff(true));
            }
            else
            {
                _history = new <TransactionLog>[log];
                commit();
            }
        }
        
        public function filter(filterFunction:Function, getter:Function = null):void
        {
            _filter = getter is Function ?
                function(list:Array):Array//配列を直接変えるので注意
                {
                    for (var i:int = 0, len:int = list.length; i < len; i++) 
                    {
                        if (filterFunction(getter(list[i]))) continue;
                        
                        list.splice(i, 1);
                        i--;
                        len--;
                    }
                    return list;
                }:
                function(list:Array):Array
                {
                    for (var i:int = 0, len:int = list.length; i < len; i++) 
                    {
                        if (filterFunction(list[i])) continue;
                        
                        list.splice(i, 1);
                        i--;
                        len--;
                    }
                    return list;
                };
            
            _list.preview(createDiff(true));
        }
        
        public function sortOn(names:*, options:* = 0, getter:Function = null):void
        {
            if ((options  & Array.RETURNINDEXEDARRAY) == 0)
                 options |= Array.RETURNINDEXEDARRAY;
            
            _sort = getter is Function ?
                function(list:Array):Array
                {
                    var dataList:Array = [];
                    
                    for (var i:int, len:int = list.length; i < len; i++)
                        dataList.push(getter(list[i]));
                    
                    return dataList.sortOn(names, options);
                }:
                function(list:Array):Array
                {
                    return list.sortOn(names, options);
                };
            
            _list.preview(createDiff(true));
        }
        
        public function rollback():void
        {
            if (isRunning())
            {
                if (_visualize)
                    _list.rollback(createDiff(true));
                
                _endTransaction();
            }
        }
        
        public function commit():void
        {
            if (isRunning())
            {
                if (!_visualize)
                    _list.preview(createDiff(true));
                
                _list.commit(createDiff(false));
                
                _endTransaction();
            }
        }
        
        private function _endTransaction():void
        {
            _visualize = false;
            _history = null;
        }
        
        public function createDiff(isPreview:Boolean):Diff
        {
            var result:Diff = isPreview ?
                new Diff(_list.originRef, _sort(_list.originRef)).salvage(_filter(_list.originClone)):
                new Diff(_list.originRef);
            
            if (_history)
                for (var i:int = 0; i < _history.length; i++)
                    _applyTransactionLog(_history[i], result);
            
            return result;
        }
        
        private function _applyTransactionLog(log:TransactionLog, diff:Diff):void
        {
            if (log.added())
            {
                diff.added.push(log);
                diff.editedOrigin.push(log.value);
            }
            else
            if (log.removed())
            {
                var n:int = diff.editedOrigin.indexOf(log.value);
                if (-1 < n)
                {
                    log._index = n;
                    diff.removed.push(log);
                    
                    diff.editedOrigin.splice(n, 1);
                    
                    diff.order[n] = -1;
                    diff.decrement(n+1);
                }
            }
        }*/
    }
}