package jp.coremind.storage
{
    import jp.coremind.utility.Log;
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.model.transaction.HashDiff;
    import jp.coremind.model.transaction.ListDiff;
    import jp.coremind.model.transaction.TransactionLog;

    public class StorageModel extends StorageAccessor
    {
        public static const TAG:String = "StorageAccessor";
        Log.addCustomTag(TAG);
        
        private var
            _reader:StorageModelReader,
            _filter:Function,
            _latestFiltered:Array,
            _sortNames:*,
            _sortOptions:int,
            _history:Vector.<TransactionLog>,
            _notifyListener:Boolean,
            _transaction:Boolean;
        
        public function StorageModel(id:String, type:String = StorageType.HASH)
        {
            _reader      = storage.requestModelReader(id, type);
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
            _transaction = true;
            _notifyListener = notifyListener;
        }
        
        public function updateValue(value:*, key:* = null):void
        {
            _history.push(new TransactionLog(value).update(key));
            _transaction ?
                _dispatch(_notifyListener, false):
                commit(true);
        }
        
        public function addValue(value:*, key:* = null):void
        {
            _history.push(new TransactionLog(value).add(key));
            _transaction ?
                _dispatch(_notifyListener, false):
                commit(true);
        }
        
        public function removeValue(value:*):void
        {
            _history.push(new TransactionLog(value).remove());
            _transaction ?
                _dispatch(_notifyListener, false):
                commit(true);
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
            
            if (notifyListener)
            {
                Log.custom(TAG, "build(preview)");
                
                diff.build(origin, _history, _sortNames, _sortOptions, _filter, _latestFiltered || []);
                
                _latestFiltered = (diff as HashDiff).filtered;
                
                _reader.dispatchByPreview(diff);
            }
            
            if (doUpdate)
            {
                Log.custom(TAG, "build(storage update)");
                
                diff.build(origin, _history);
                
                storage.update(this, _reader._origin = diff.editedOrigin);
                
                _deleteStorageModel(diff);
                
                _reader.dispatchByCommit(diff);
            }
        }
        
        private function _deleteStorageModel(diff:Diff):void
        {
            var listDiff:ListDiff = diff as ListDiff;
            
            if (listDiff)
                for (var i:int = 0; i < listDiff.removed.length; i++) 
                    storage.de1ete(_reader.id+"."+listDiff.removed[i].index, _reader.type);
        }
    }
}