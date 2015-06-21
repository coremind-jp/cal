package jp.coremind.utility
{
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import jp.coremind.control.Application;
    import jp.coremind.data.FlickAcceleration;

    public class Flick extends Drug
    {
        private var
            _flickX:FlickAcceleration,
            _flickY:FlickAcceleration,
            _destroy:Boolean;
        
        public function Flick(adsorbThreshold:Number = 10)
        {
            super(adsorbThreshold);
            
            _destroy = false;
            _flickX = new FlickAcceleration();
            _flickY = new FlickAcceleration();
            
            $.loop.highResolution.setInterval(_update);
        }
        
        override public function destory():void
        {
            _destroy = true;
            _flickX = _flickY = null;
            
            super.destory();
        }
        
        override public function observe(callback:Function, offset:Rectangle, drugSize:Rectangle = null):void
        {
            super.observe(callback, offset, drugSize);
            _trackX.enabledRound = _trackY.enabledRound = false;
            
            _flickX.terminate();
            _flickY.terminate();
        }
        
        protected function _update(elapsed:int):Boolean
        {
            if (!_destroy && !_druging && _trackX && _trackY)
            {
                _flickX.update(_trackX, elapsed);
                _flickY.update(_trackY, elapsed);
                
                _callback(_trackX, _trackY);
            }
            
            return _destroy;
        }
        
        override protected function _onUp(e:MouseEvent):void
        {
            Application.stage.removeEventListener(MouseEvent.MOUSE_UP, _onUp);
            _druging = false;//terminate drug loop.
            
            _flickX.initialize(_trackX);
            _flickY.initialize(_trackY);
        }
    }
}