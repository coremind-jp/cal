package jp.coremind.storage
{
    import flash.utils.Dictionary;
    
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.utility.Log;
    
    /**
     * Storageクラスに格納されているデータの読み出しと変更監視の制御するクラス.
     */
    public class ModelReader extends StorageAccessor
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
            _listenerList:Vector.<IModelStorageListener>;
        
        public function ModelReader(id:String, type:String = StorageType.HASH)
        {
            _id               = id;
            _type             = type;
            _priorityList     = new Dictionary(true);
            _listenerList     = new <IModelStorageListener>[];
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
        public function read():* { return /*_origin ? _origin: _origin =*/ storage.read(this); }
        /** reader alias */
        
        public function hasListener():Boolean
        {
            return _listenerList.length != 0;
        }
        
        public function createModelKeyList():Array
        {
            var result:Array = [];
            var storageData:* = read();
            
            if (storageData is Array)
                for (var i:int = 0, len:int = storageData.length; i < len; i++) 
                    result[i] = i;
            else
            if ($.isHash(storageData))
                for (var p:String in storageData)
                    result.push(p);
            
            return result;
        }
        
        public function addListener(listener:IModelStorageListener, priority:int = 0):void
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
        
        public function removeListener(listener:IModelStorageListener):void
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