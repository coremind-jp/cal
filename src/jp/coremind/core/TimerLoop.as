package jp.coremind.core
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import jp.coremind.data.Progress;

    public class TimerLoop extends Loop
    {
        private var _timer:Timer;
        
        public function TimerLoop(delay:int)
        {
            super();
            
            _timer = new Timer(delay);
            _timer.addEventListener(TimerEvent.TIMER, _onTime);
            _timer.start();
        }
        
        override public function terminate():void
        {
            _timer.removeEventListener(TimerEvent.TIMER, _onTime);
            _timer.reset();
            _timer = null;
            
            super.terminate();
        }
        
        private function _onTime(e:TimerEvent):void
        {
            _update(getTimer());
        }
        
        override public function pushHandler(delay:int, completeClosure:Function, updateClosure:Function = null):void
        {
            var _start:int = getTimer();
            var _done:int  = _start + delay;
            var _progress:Progress = new Progress();
            
            _progress.setRange(_start, _done);
            
            _handlerList.push(updateClosure is Function ?
                function(now:int):Boolean
                {
                    _progress.update(now);
                    
                    if (_progress.gain == delay)
                    {
                        completeClosure(_progress);
                        return true;
                    }
                    else
                        return updateClosure(_progress);
                }:
                function(now:int):Boolean
                {
                    _progress.update(now);
                    
                    if (_progress.gain == delay)
                    {
                        completeClosure(_progress);
                        return true;
                    }
                    else
                        return false;
                });
        }
        
        public function setInterval(f:Function, ...args):void
        {
            var _elapsed:int = getTimer();
            args.unshift(_elapsed);
            
            _handlerList.push(function(now:int):Boolean
            {
                args[0]  = now - _elapsed;
                _elapsed = now;
                return $.apply(f, args);
            });
        }
    }
}