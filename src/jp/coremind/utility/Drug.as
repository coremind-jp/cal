package jp.coremind.utility
{
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.data.NumberTracker;

    public class Drug extends EventDispatcher
    {
        protected var
            _druging:Boolean,
            _adsorbThreshold:Number,
            _drugListener:Function,
            _dropListener:Function,
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
            _drugListener = _dropListener = null;
            _trackX = _trackY = null;
        }
        
        public function observe(drugListener:Function, dropListener:Function, offset:Rectangle, drugArea:Rectangle = null):void
        {
            if (_druging)
                return;
            
            drugArea = drugArea || new Rectangle(0, 0, Application.stage.width, Application.stage.height);
            
            _druging = true;
            _drugListener = drugListener;
            _dropListener = dropListener;
            
            _trackX = new NumberTracker();
            _trackX.setRange(drugArea.left + offset.x, drugArea.right - offset.width + offset.x);
            _trackX.initialize(Application.stage.mouseX);
            
            _trackY = new NumberTracker();
            _trackY.setRange(drugArea.top + offset.y, drugArea.bottom - offset.height + offset.y);
            _trackY.initialize(drugArea.bottom + offset.y);
            
            $.loop.highResolution.setInterval(_onUpdate);
            Application.stage.addEventListener(MouseEvent.MOUSE_UP, _onUp);
        }
        
        protected function _onUpdate(elapsed:int):Boolean
        {
            return update(Application.stage.mouseX, Application.stage.mouseY);
        }
        
        public function update(x:Number, y:Number):Boolean
        {
            if (!_druging) return true;
            
            x = _applyOutOfRangeRevision(x, _trackX);
            y = _applyOutOfRangeRevision(y, _trackY);
            
            if (_isAdsorb(_trackX.start - x, _trackY.start - y))
            {
                x = _trackX.start;
                y = _trackY.start;
            }
            
            var changedX:Boolean = _trackX.update(x);
            var changedY:Boolean = _trackY.update(y);
            if (changedX || changedY) _drugListener(_trackX, _trackY);
            
            return false;
        }
        
        private function _isAdsorb(x:Number, y:Number):Boolean
        {
            return -_adsorbThreshold < x && x < _adsorbThreshold
                && -_adsorbThreshold < y && y < _adsorbThreshold;
        }
        
        private function _applyOutOfRangeRevision(n:Number, v:NumberTracker):Number
        {
            var overflow:Number;
            var d:int = v.distance >> 1;
            
            if (n < v.min)
            {
                overflow = (v.min - n) >> 1;
                return d < overflow ? v.min - d: v.min - overflow;
            }
            else
            if (v.max < n)
            {
                overflow = (n - v.max) >> 1;
                return d < overflow ? v.max + d: v.max + overflow;
            }
            else
                return n;
        }
        
        protected function _onUp(e:MouseEvent):void
        {
            _dropListener(_trackX, _trackX);
            destory();
        }
    }
}