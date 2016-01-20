package jp.coremind.utility
{
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;

    public class Delay
    {
        private static const UNDEFINED_TIMER_ID:uint = uint.MAX_VALUE;
        
        private var _timeoutId:uint;
        
        public function Delay()
        {
            _timeoutId = UNDEFINED_TIMER_ID;
        }
        
        public function start(delay:int, callback:Function):void
        {
            if (delay <= 0)
                callback();
            else
            if (_timeoutId == UNDEFINED_TIMER_ID)
                _timeoutId = setTimeout(callback, delay);
            else
            {
                stop();
                start.apply(null, arguments);
            }
        }
        
        public function get running():Boolean
        {
            return _timeoutId != UNDEFINED_TIMER_ID;
        }
        
        public function stop():void
        {
            if (_timeoutId != UNDEFINED_TIMER_ID)
            {
                clearTimeout(_timeoutId);
                _timeoutId = UNDEFINED_TIMER_ID;
            }
        }
    }
}