package jp.coremind.storage
{
    import flash.utils.Dictionary;
    
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.model.transaction.Diff;
    
    /**
     * Storageクラスに格納されているデータの読み出しと変更監視の制御するクラス.
     */
    public class StorageModelReader extends StorageAccessor
    {
        public static const LISTENER_PRIORITY_ELEMENT             :int = 0;
        public static const LISTENER_PRIORITY_GRID_LAYOUT         :int = 100;
        public static const LISTENER_PRIORITY_LIST_ELEMENT_FACTORY:int = 200;
        
        internal var
            _origin:*;
        
        protected var
            _id:String,
            _type:String,
            _priorityList:Dictionary,
            _listenerList:Vector.<IStorageListener>;
        
        public function StorageModelReader(id:String, type:String = StorageType.HASH)
        {
            _id               = id;
            _type             = type;
            _priorityList     = new Dictionary(true);
            _listenerList     = new <IStorageListener>[];
        }
        
        public function destroy():void
        {
            var p:*;
            
            _origin = null;
            
            for (p in _priorityList)  delete _priorityList[p];
            
            _listenerList.length = 0;
        }
        
        /** reader alias */
        public function get id():String   { return _id; }
        public function get type():String { return _type; }
        public function read():* { return _origin ? _origin: _origin = _storage.read(this); }
        /** reader alias */
        
        public function hasListener():Boolean
        {
            return _listenerList.length != 0;
        }
        
        public function addListener(listener:IStorageListener, priority:int = 0):void
        {
            if (listener in _priorityList) return;
            
            _priorityList[listener] = priority;
            for (var i:int = 0, len:int = _listenerList.length; i < len; i++) 
            {
                if (_priorityList[_listenerList[i]] < priority)
                {
                    _listenerList.splice(i, 0, listener);
                    return;
                }
            }
            
            _listenerList.push(listener);
        }
        
        public function removeListener(listener:IStorageListener):void
        {
            if (listener in _priorityList)
            {
                delete _priorityList[listener];
                _listenerList.splice(_listenerList.indexOf(listener), 1);
            }
        }
        
        public function dispatchByPreview(diff:Diff):void
        {
            for (var i:int = 0; i < _listenerList.length; i++) 
                _listenerList[i].preview(diff);
        }
        
        public function dispatchByCommit(diff:Diff):void
        {
            for (var i:int = 0; i < _listenerList.length; i++) 
                _listenerList[i].commit(diff);
        }
    }
}