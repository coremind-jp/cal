package jp.coremind.utility
{
    import flash.utils.Dictionary;
    
    public class Dispatcher implements IDispatcher
    {
        protected var
            _priorityList:Dictionary,
            _listenerList:Vector.<Function>;
        
        public function Dispatcher()
        {
            _priorityList = new Dictionary(true);
            _listenerList = new <Function>[];
        }
        
        public function destroy():void
        {
            for (var listener:Function in _priorityList)
                delete _priorityList[listener]
            
            _listenerList.length = 0;
        }
        
        public function addListener(listener:Function, priority:int = 0):void
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
        
        public function hasListener(listener:Function):Boolean
        {
            return listener in _priorityList;
        }
        
        public function removeListener(listener:Function):void
        {
            if (listener in _priorityList)
            {
                delete _priorityList[listener];
                _listenerList.splice(_listenerList.indexOf(listener), 1);
            }
        }
        
        public function removeListeners():void
        {
            for (var listener:Function in _priorityList)
                removeListener(listener);
        }
        
        public function dispatch(...params):void
        {
            for (var i:int = 0; i < _listenerList.length; i++) 
                _listenerList[i].apply(null, params);
        }
    }
}