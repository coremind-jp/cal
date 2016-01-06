package jp.coremind.utility.process
{
    import flash.utils.getTimer;
    
    import jp.coremind.utility.data.Progress;
    
    import starling.animation.IAnimatable;
    import starling.core.Starling;

    public class JugglerLoop extends Loop implements IAnimatable
    {
        public function JugglerLoop()
        {
            super();
            
            Starling.juggler.add(this);
        }
        
        public function advanceTime(time:Number):void
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