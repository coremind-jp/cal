package jp.coremind.model
{
    /**
     * Storageクラスに格納されているデータの読み出しと変更監視の制御するクラス.
     */
    public class StorageModelReader implements IModel
    {
        internal var
            _origin:*;
        
        protected var
            _id:String,
            _type:String,
            _runtime:RuntimeModelAccessor,
            _listeners:Vector.<IStorageListener>;
        
        public function StorageModelReader(id:String, type:String = StorageType.HASH)
        {
            _id        = id;
            _type      = type;
            _runtime   = new RuntimeModelAccessor(id);
            _listeners = new <IStorageListener>[];
        }
        
        public function destroy():void
        {
            _origin = null;
            
            _listeners.length = 0;
            
            _runtime.removeAllModel(_id);
            _runtime.destroy();
        }
        
        public function get id():String                    { return _id; }
        public function get type():String                  { return _type; }
        public function get runtime():RuntimeModelAccessor { return _runtime; }
        public function read():* { return _origin ? _origin: _origin = Storage.read(this); }
        
        public function hasListener():Boolean
        {
            return _listeners.length != 0;
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
        
        public function dispatchByPreview(diff:Diff):void
        {
            for (var i:int = 0; i < _listeners.length; i++) 
                _listeners[i].preview(diff);
        }
        
        public function dispatchByCommit(diff:Diff):void
        {
            for (var i:int = 0; i < _listeners.length; i++) 
                _listeners[i].commit(diff);
        }
    }
}