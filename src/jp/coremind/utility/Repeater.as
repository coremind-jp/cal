package jp.coremind.utility
{
    import flash.utils.clearInterval;
    import flash.utils.clearTimeout;
    import flash.utils.setInterval;
    import flash.utils.setTimeout;

    public class Repeater
    {
        private static const UNDEFINED_TIMER_ID:uint = 0xFFFFFFFF;
        
        private var
            _isRunning:Boolean,
            _intervalId:uint,
            _timeoutId:uint;
        
        public function Repeater()
        {
            _intervalId = _timeoutId  = UNDEFINED_TIMER_ID;
        }
        
        public function start(delay:int, interval:int, closure:Function):void
        {
            if (_isRunning) stop();
            
            _isRunning = true;
            
            _timeoutId = setTimeout(function():void {
                _intervalId = setInterval(closure, interval);
            }, delay);
            
            closure();
        }
        
        public function stop():void
        {
            if (!_isRunning) return;
            
            _isRunning = false;
            
            if (_timeoutId != UNDEFINED_TIMER_ID)
            {
                clearTimeout(  _timeoutId);
                _timeoutId = UNDEFINED_TIMER_ID;
            }
            
            if (_intervalId != UNDEFINED_TIMER_ID)
            {
                clearInterval(_intervalId);
                _intervalId = UNDEFINED_TIMER_ID;
            }
        }
    }
}