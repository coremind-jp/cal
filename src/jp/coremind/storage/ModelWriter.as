package jp.coremind.storage
{
    import flash.utils.Dictionary;
    
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.model.transaction.HashDiff;
    import jp.coremind.model.transaction.ListDiff;
    import jp.coremind.model.transaction.TransactionLog;
    import jp.coremind.utility.Log;

    public class ModelWriter extends StorageAccessor
    {
        public static const TAG:String = "[ModelWriter]";
        Log.addCustomTag(TAG);
        
        private var
            _reader:ModelReader,
            _filter:Function,
            _latestFiltered:Dictionary,
            _sortNames:*,
            _sortOptions:int,
            _history:Vector.<TransactionLog>,
            _notifyListener:Boolean,
            _transaction:Boolean;
        
        public function ModelWriter(id:String, type:String = StorageType.HASH)
        {
            _reader      = storage.requestReader(id, type);
            _filter      = null;
            _sortNames   = null;
            _sortOptions = 0;
            _history     = new <TransactionLog>[];
            _transaction = false;
        }
        
        public function destroy():void
        {
            _reader = null;
            
            _filter = null;
            
            _history.length = 0;
            
            if (_latestFiltered)
                _latestFiltered.length = 0;
            _latestFiltered = null;
        }
        
        public function get transaction():Boolean { return _transaction; }
        
        public function get id():String           { return _reader.id; }
        public function get type():String         { return _reader.type; }
        public function read():*                  { return _reader.read(); }
        
        public function filter(f:Function):void
        {
            if (_filter === f)
                return;
            
            Log.custom(TAG, "filter");
            _filter = f;
            _dispatch(true, false);
        }
        
        public function sortOn(names:*, options:* = 0):void
        {
            if (_sortNames === names && _sortOptions === options)
                return;
            
            Log.custom(TAG, "sortOn", names, options);
            _sortNames   = names;
            _sortOptions = options;
            _dispatch(true, false);
        }
        
        public function beginTransaction(notifyListener:Boolean = true):void
        {
            if (_transaction)
                return;
            
            Log.custom(TAG, "beginTransaction");
            _transaction    = true;
            _notifyListener = notifyListener;
        }
        
        public function updateValue(value:*, key:* = null):void
        {
            _history.push(new TransactionLog(value).update(key));
            _transaction ? _dispatch(_notifyListener, false): commit(true);
        }
        
        public function addValue(value:*, key:* = null):void
        {
            _history.push(new TransactionLog(value).add(key));
            _transaction ? _dispatch(_notifyListener, false): commit(true);
        }
        
        public function removeValue(value:*):void
        {
            _history.push(new TransactionLog(value).remove());
            _transaction ? _dispatch(_notifyListener, false): commit(true);
        }
        
        public function swapValue(valueFrom:*, valueTo:*):void
        {
            _history.push(new TransactionLog(valueFrom).swap(valueTo));
            _transaction ? _dispatch(_notifyListener, false): commit(true);
        }
        
        public function moveValue(valueFrom:*, valueTo:*):void
        {
            _history.push(new TransactionLog(valueFrom).move(valueTo));
            _transaction ? _dispatch(_notifyListener, false): commit(true);
        }
        
        public function undoTransactionHistory(notifyListener:Boolean = true):void
        {
            if (_history.length > 0)
            {
                _history.pop();
                
                if (notifyListener)
                    _transaction ? _dispatch(_notifyListener, false): commit(true);
            }
        }
        
        public function rollback(notifyListener:Boolean = true):void
        {
            if (_transaction)
            {
                Log.custom(TAG, "rollback");
                _history.length = 0;
                _dispatch(notifyListener, false);
                _transaction    = false;
                _notifyListener = false;
            }
        }
        
        public function commit(notifyListener:Boolean = true):void
        {
            if (_history.length > 0)
            {
                Log.custom(TAG, "commit");
                _dispatch(notifyListener, true);
                _history.length = 0;
                _transaction    = false;
                _notifyListener = false;
            }
        }
        
        private function _dispatch(notifyListener:Boolean, doUpdate:Boolean):void
        {
            var i:int;
            var origin:*  = read();
            var diff:Diff = $.isPrimitive(origin) ? new Diff():
                            $.isArray(origin)     ? new ListDiff(): new HashDiff();
            
            if (doUpdate)
            {
                Log.custom(TAG, "build(storage update)");
                diff.build(origin, _history);
                _latestFiltered = null;
                
                _updateStorage(diff);
            }
            else
            {
                Log.custom(TAG, "build(preview)");
                diff.build(origin, _history, _sortNames, _sortOptions, _filter, _latestFiltered);
                _latestFiltered = (diff as ListDiff).filtered;
            }
            
            if (doUpdate)
                _reader.dispatchByCommit(diff);
            else
            if (notifyListener)
                _reader.dispatchByPreview(diff);
        }
        
        private function _updateStorage(diff:Diff):void
        {
            //orderはeditedOriginに反映されていないのでStorage::updateを呼ぶ前に反映させる必要がある.
            //storage.update(this, diff is ListDiff ? _applyOrder(diff as ListDiff): diff.editedOrigin);
            storage.update(this, diff.editedOrigin);
            _destroyModel(diff);
        }
        
        private function _applyOrder(diff:ListDiff):Array
        {
            if (diff && diff.order)
            {
                var result:Array = [];
                for (var i:int = 0, len:int = diff.editedOrigin.length; i < len; i++) 
                    result[i] = diff.editedOrigin[ diff.order[i] ];
                
                //元データを削除
                diff.editedOrigin.length = 0;
                
                return result;
            }
            else return diff.editedOrigin;
        }
        
        private function _destroyModel(diff:Diff):void
        {
            var listDiff:ListDiff = diff as ListDiff;
            
            if (listDiff)
                for (var i:int = 0; i < listDiff.removed.length; i++) 
                    storage.destroy(_reader.id+"."+listDiff.removed[i].index, _reader.type);
        }
    }
}