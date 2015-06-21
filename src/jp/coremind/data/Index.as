package jp.coremind.data
{
    public class Index
    {
        public var
            linked:Boolean;
        
        private var
            _length:int,
            _head:int;
        
        public function Index()
        {
            linked = false;
            _length = _head = 0;
        }
        
        public function get length():int  { return _length; }
        public function get head():int    { return _head; }
        
        public function isFirst():Boolean { return _head == 0; }
        public function isLast():Boolean  { return length > 0 && _head == length - 1; }
        
        public function refreshLength(value:int = 0):void
        {
            _length = value < 0 ? 0: value;
            jump(_head);
        }
        
        public function next():Boolean { return _head != _incrementHead(); }
        private function _incrementHead():int
        {
            if (length > 0)
            {
                var _next:int = _head + 1;
                _head = length <= _next ?
                    linked ? 0: _head:
                    _next;
            }
            
            return _head;
        }
        
        public function prev():Boolean { return _head != _decrementHead(); }
        private function _decrementHead():int
        {
            if (length > 0)
            {
                var _prev:int = _head - 1;
                _head = _prev < 0 ?
                    linked ? length-1: _head:
                    _prev;
            }
            
            return _head;
        }
        
        public function jump(to:int):void
        {
            if      (to < 0)      _head = 0;
            else if (to < length) _head = to;
            else                  _head = lastIndex;
        }
        private function get lastIndex():int { return 0 < length ? length - 1: 0; }
    }
}