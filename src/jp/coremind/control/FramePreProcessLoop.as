package jp.coremind.control
{
    import flash.events.Event;

    public class FramePreProcessLoop extends FrameLoop
    {
        public function FramePreProcessLoop()
        {
            super();
            
            _sprite.addEventListener(Event.ENTER_FRAME, _update);
        }
        
        override public function terminate():void
        {
            _sprite.removeEventListener(Event.ENTER_FRAME, _update);
            
            super.terminate();
        }
    }
}