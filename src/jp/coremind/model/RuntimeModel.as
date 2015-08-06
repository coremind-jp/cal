package jp.coremind.model
{
    public class RuntimeModel
    {
        protected var
            _listenerList:Vector.<Function>;
            
        public function RuntimeModel()
        {
            _listenerList = new <Function>[];
        }
        
        public function addListener(listener:Function):void
        {
            if (_listenerList.indexOf(listener) == -1)
                _listenerList.push(listener);
        }
        
        public function removeListener(listener:Function):void
        {
            var n:int = _listenerList.indexOf(listener);
            if (n != -1) _listenerList.splice(n, 1);
        }
        
        protected function _dispatch(...params):void
        {
            for (var i:int = 0; i < _listenerList.length; i++) 
                _listenerList[i].apply(null, params);
        }
    }
}