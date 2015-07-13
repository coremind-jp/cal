package jp.coremind.core
{
    import flash.display.Sprite;
    import jp.coremind.data.Progress;
    

    public class FrameLoop extends Loop
    {
        protected var _sprite:Sprite;
        
        public function FrameLoop()
        {
            super();
            
            _sprite = new Sprite();
        }
        
        override public function terminate():void
        {
            _sprite = null;
            
            super.terminate();
        }
        
        override public function pushHandler(delay:int, completeClosure:Function, updateClosure:Function = null):void
        {
            var _progress:Progress = new Progress();
            
            _progress.setRange(0, delay);
            
            _handlerList.push(updateClosure is Function ?
                function(v:*):Boolean
                {
                    _progress.update(_progress.now + 1);
                    
                    if (_progress.gain == delay)
                    {
                        completeClosure(_progress);
                        return true;
                    }
                    else
                        return updateClosure(_progress);
                }:
                function(v:*):Boolean
                {
                    _progress.update(_progress.now + 1);
                    
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
            _handlerList.push(function(v:*):Boolean { return $.apply(f, args); });
        }
    }
}