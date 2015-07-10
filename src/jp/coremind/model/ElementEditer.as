package jp.coremind.model
{
    public class ElementEditer
    {
        private var
            _transaction:Boolean,
            _edited:Object,
            _origin:Object,
            _callback:Function;
            
        public function ElementEditer(originHash:Object, refreshCallback:Function)
        {
            _transaction = false;
            _origin = originHash;
            _callback = refreshCallback;
        }
        
        public function destroy():void
        {
            _origin = _edited = null;
            _callback = null;
        }
        
        public function beginTransaction():void
        {
            _transaction = true;
            _edited = $.clone(_origin);
        }
        
        public function deleteElement(id:*, visualize:Boolean):void
        {
            var i:int = _origin.indexOf(id);
            
            if (i > -1)
                _transaction ? _edited.slice(i, 1): _callback(_origin, null, i, visualize);
        }
        
        public function endTransaction():void
        {
            _transaction = false;
            _callback(_origin, _edited, -1, true);
        }
    }
}