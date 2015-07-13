package jp.coremind.model
{
    import jp.coremind.core.Application;
    import jp.coremind.model.storage.StorageType;
    import jp.coremind.utility.Log;
    import jp.coremind.model.storage.IStorageListener;

    public class StorageAccessor
    {
        public static const TAG:String = "StorageAccessor";
        Log.addCustomTag(TAG);
        
        private var
            _filter:Function,
            _sortNames:*,
            _sortOptions:int,
            
            _origin:*,
            
            _history:Vector.<TransactionLog>,
            
            _listeners:Vector.<IStorageListener>,
            _latestFiltered:Array,
            _parent:StorageAccessor,
            
            _notifyListener:Boolean,
            _transaction:Boolean,
            _grobalId:String,
            _localId:String,
            _type:String;
        
        public function StorageAccessor(id:String, type:String = StorageType.RUNTIME_HASH)
        {
            _filter      = null;
            _sortNames   = null;
            _sortOptions = 0;
            
            _listeners   = new <IStorageListener>[];
            _history     = new <TransactionLog>[];
            _parent      = null;
            _transaction = false;
            _grobalId    = id;
            _localId     = null;
            _type        = type;
        }
        
        public function destroy():void
        {
            _filter = null;
            
            _listeners.length = 0;
            _history.length = 0;
            _parent = null;
        }
        
        public function get type():String { return _type; }
        public function get globalId():String { return _localId ? _grobalId+"."+_localId: _grobalId; }
        public function get localId():String  { return _localId; }
        public function get parent():StorageAccessor { return _parent; }
        public function get transaction():Boolean { return _transaction; }
        
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
        
        public function createChild(localId:String):StorageAccessor
        {
            return new StorageAccessor(_grobalId, _type)
                .updateLocalId(localId)
                .updateParentModel(this);
        }
        
        public function addListener(listener:IStorageListener):void
        {
            var n:int = _listeners.indexOf(listener);
            if (n == -1) _listeners.push(listener);
        }
        
        public function removeListener(listener:IStorageListener):void
        {
            var n:int = _listeners.indexOf(listener);
            if (n != -1) _listeners.splice(n, 1);
        }
        
        public function read():*
        {
            return _origin ? _origin: _origin = Application.storage.read(this);
        }
        
        public function updateLocalId(id:String):StorageAccessor
        {
            _localId = id;
            return this;
        }
        
        public function updateParentModel(parent:StorageAccessor):StorageAccessor
        {
            _parent  = parent;
            return this;
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
                
                for (i = 0; i < _listeners.length; i++) 
                    _listeners[i].preview(diff);
            }
            
            if (doUpdate)
            {
                Log.custom(TAG, "build(storage update)");
                diff.build(origin, _history);
                Application.storage.update(this, _origin = diff.editedOrigin);
                
                for (i = 0; i < _listeners.length; i++) 
                    _listeners[i].commit(diff);
            }
        }
    }
}