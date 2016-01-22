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
        
        /**
         * クロージャの遅延実行を始める.
         * delayパラメータが0以下の場合、startの呼び出しと同期的に実行される.
         * 既にstartが呼ばれている状態で再びstartを呼び出した場合、直前の呼び出しはキャンセルされる.
         */
        public function exec(closure:Function, delay:int, ...args):void
        {
            if (_timeoutId == UNDEFINED_TIMER_ID)
            {
                delay <= 0 ?
                    closure.apply(null, args):
                    _timeoutId = setTimeout(function():void { closure.apply(null, args); cancel(); }, delay);
            }
            else
            {
                cancel();
                
                args.unshift(closure, delay);
                exec.apply(null, args);
            }
        }
        
        /**
         * 遅延実行か開始されているかを示す値を返す.
         */
        public function get running():Boolean
        {
            return _timeoutId != UNDEFINED_TIMER_ID;
        }
        
        /**
         * クロージャの遅延実行をキャンセルする.
         */
        public function cancel():void
        {
            if (_timeoutId != UNDEFINED_TIMER_ID)
            {
                clearTimeout(_timeoutId);
                _timeoutId = UNDEFINED_TIMER_ID;
            }
        }
    }
}