package jp.coremind.view.starling
{
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.Log;
    
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class InteractiveElement extends Element
    {
        private static const _HIT_TEST:Rectangle = new Rectangle(0, 0, 1, 1);
        
        private var
            _tapRange:Rectangle,
            _hold:Boolean,
            _hover:Boolean;
        
        public function InteractiveElement(tapRange:Number = 5)
        {
            super();
            
            _hold = _hover = false;
            _tapRange = new Rectangle();
            
            setTapRange(tapRange);
            enablePointerDeviceControl();
        }
        
        override public function destroy():void
        {
            disablePointerDeviceControl();
            super.destroy();
        }
        
        public function setTapRange(n:Number):void
        {
            _tapRange.inflate(n, n);
        }
        
        protected function _onTouch(e:TouchEvent):void
        {
            var  t:Touch = e.getTouch(this);
            if (!t)
            {
                if (_hover)
                {
                    _hover = false;
                    _onRollOut();
                }
                return;
            }
            
            if (t.phase  === TouchPhase.HOVER && !_hover)
            {
                _hover = true;
                _onRollOver(t);
            }
            else
            if (t.phase === TouchPhase.MOVED)
            {
                _HIT_TEST.x = t.globalX;
                _HIT_TEST.y = t.globalY;
                _hold = _tapRange.intersects(_HIT_TEST);
                _onMove(t);
            }
            else
            if (t.phase  === TouchPhase.BEGAN)
            {
                _tapRange.x = t.globalX;
                _tapRange.y = t.globalY;
                _hold = true;
                _onDown(t);
            }
            else
            if (t.phase === TouchPhase.ENDED)
                _hold ? _onTap(t): _onUp(t);
        }
        
        protected function _onRollOver(t:Touch):void
        {
            //Log.info("roll over");
        }
        
        protected function _onRollOut():void
        {
            //Log.info("roll out");
        }
        
        protected function _onMove(t:Touch):void
        {
            //Log.info("_onMove");
        }
        
        protected function _onDown(t:Touch):void
        {
            //Log.info("_onDown");
        }
        
        protected function _onUp(t:Touch):void
        {
            //Log.info("_onUp");
        }
        
        protected function _onTap(t:Touch):void
        {
            //Log.info("_onTap");
        }
        
        override public function enablePointerDeviceControl():void
        {
            touchable = true;
            addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        override public function disablePointerDeviceControl():void
        {
            touchable = false;
            removeEventListener(TouchEvent.TOUCH, _onTouch);
        }
    }
}