package jp.coremind.utility
{
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import jp.coremind.control.Application;
    import jp.coremind.data.NumberTracker;

    public class Drug extends EventDispatcher
    {
        protected var
            _druging:Boolean,
            _adsorbThreshold:Number,
            _callback:Function,
            _trackX:NumberTracker,
            _trackY:NumberTracker;
        
        public function Drug(adsorbThreshold:Number = 10)
        {
            _druging = false;
            _adsorbThreshold = Math.abs(adsorbThreshold);
        }
        
        public function destory():void
        {
            Application.stage.removeEventListener(MouseEvent.MOUSE_UP, _onUp);
            
            _druging = false;
            _callback = null;
            _trackX = _trackY = null;
        }
        
        public function observe(callback:Function, offset:Rectangle, drugSize:Rectangle = null):void
        {
            if (_druging)
                return;
            
            drugSize = drugSize || new Rectangle(0, 0, Application.stage.width, Application.stage.height);
            
            _druging = true;
            _callback = callback;
            
            _trackX = new NumberTracker();
            _trackX.setRange(drugSize.left + offset.x, drugSize.right - (offset.width - offset.x));
            _trackX.initialize(Application.stage.mouseX);
            
            _trackY = new NumberTracker();
            _trackY.setRange(drugSize.top + offset.y, drugSize.bottom - (offset.height - offset.y));
            _trackY.initialize(Application.stage.mouseY);
            
            $.loop.highResolution.setInterval(_onUpdate);
            Application.stage.addEventListener(MouseEvent.MOUSE_UP, _onUp);
        }
        
        private function _onUpdate(elapsed:int):Boolean
        {
            update(Application.stage.mouseX, Application.stage.mouseY);
            return !_druging;
        }
        
        public function update(x:Number, y:Number):void
        {
            if (!_druging)
                return;
            
            x = _applyOutOfRangeCoeciendce(x, _trackX);
            y = _applyOutOfRangeCoeciendce(y, _trackY);
            
            if (_isAdsorb(_trackX.start - x, _trackY.start - y))
            {
                x = _trackX.start;
                y = _trackY.start;
            }
            
            var rX:Boolean = _trackX.update(x);
            var rY:Boolean = _trackY.update(y);
            if (rX || rY) _callback(_trackX, _trackY);
        }
        
        private function _isAdsorb(x:Number, y:Number):Boolean
        {
            return -_adsorbThreshold < x && x < _adsorbThreshold
                && -_adsorbThreshold < y && y < _adsorbThreshold;
        }
        
        private function _applyOutOfRangeCoeciendce(n:Number, v:NumberTracker):Number
        {
            return n < v.min || v.max < n ? v.now + (n - v.now) * .05: n;
        }
        
        protected function _onUp(e:MouseEvent):void
        {
            destory();
        }
    }
}