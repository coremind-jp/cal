package jp.coremind.control
{
    import flash.events.Event;

    public class FramePostProcessLoop extends FrameLoop
    {
        public function FramePostProcessLoop()
        {
            super();
            
            _sprite.addEventListener(Event.EXIT_FRAME, _update);
        }
        
        override public function terminate():void
        {
            _sprite.removeEventListener(Event.EXIT_FRAME, _update);
            
            super.terminate();
        }
    }
}