package jp.coremind.utility.data
{
    public class NumberTracker extends Progress
    {
        private var
            _start:Number,
            _prevent:Number,
            _preventDelta:Number,
            _totalDelta:Number;
        
        public function NumberTracker()
        {
            _start = _preventDelta = _prevent = _totalDelta = 0;
        }
        
        public function initialize(start:Number, threshold:Number = 0):void
        {
            _preventDelta = _totalDelta = 0;
            
            _start = _prevent = start;
            update(_start);
        }
        
        override public function update(n:Number):Boolean
        {
            _prevent = now;
            
            super.update(n);
            
            _preventDelta = now - _prevent;
            _totalDelta   = now - _start;
            
            return _prevent !== now;
        }
        
        public function get start():Number
        {
            return _start;
        }

        public function get prevent():Number
        {
            return _prevent;
        }
        
        public function get preventDelta():Number
        {
            return _preventDelta;
        }
        
        public function get totalDelta():Number
        {
            return _totalDelta;
        }
        
        override public function toString():String
        {
            return super.toString()+" start="+_start+" prevent="+_prevent+" preventDelta="+_preventDelta+" totalDelta="+_totalDelta;
        }
    }
}