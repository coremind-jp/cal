package jp.coremind.utility
{
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.view.transition.FlickAcceleration;
    import jp.coremind.data.NumberTracker;

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
        }
        
        override public function destory():void
        {
            _destroy = true;
            _flickX = _flickY = null;
            
            super.destory();
        }
        
        override public function observe(drugListener:Function, dropListener:Function, offset:Rectangle, drugArea:Rectangle = null):void
        {
            if (_druging)
                return;
            
            _flickX.terminate();
            _flickY.terminate();
            
            _druging = true;
            _drugListener = drugListener;
            _dropListener = dropListener;
            
            drugArea = drugArea || new Rectangle(0, 0, Application.stage.width, Application.stage.height);
            
            _trackX = new NumberTracker();
            _trackX.enabledRound = false;
            _trackX.setRange(drugArea.left + offset.x, drugArea.right - (offset.width - offset.x));
            _trackX.initialize(Application.stage.mouseX);
            
            _trackY = new NumberTracker();
            _trackY.enabledRound = false;
            _trackY.setRange(drugArea.top + offset.y, drugArea.bottom - (offset.height - offset.y));
            _trackY.initialize(Application.stage.mouseY);
            
            $.loop.highResolution.setInterval(_onUpdate);
            Application.stage.addEventListener(MouseEvent.MOUSE_UP, _onUp);
        }
        
        public function updateRange(offset:Rectangle, drugArea:Rectangle = null):void
        {
            if (_trackX && _trackY)
            {
                drugArea = drugArea || new Rectangle(0, 0, Application.stage.width, Application.stage.height);
                _trackX.setRange(drugArea.left + offset.x, drugArea.right - (offset.width - offset.x));
                _trackY.setRange(drugArea.top + offset.y, drugArea.bottom - (offset.height - offset.y));
            }
        }
        
        override protected function _onUp(e:MouseEvent):void
        {
            Application.stage.removeEventListener(MouseEvent.MOUSE_UP, _onUp);
            
            //terminate drug loop.
            _druging = false;
            
            _dropListener(_trackX, _trackY);
            
            if (_flickX.requireUpdate(_trackX) || _flickY.requireUpdate(_trackY))
            {
                _flickX.initialize(_trackX);
                _flickY.initialize(_trackY);
                $.loop.highResolution.setInterval(_update);
            }
        }
        
        protected function _update(elapsed:int):Boolean
        {
            if (_destroy) return true;
            
            var _changedX:Boolean = _flickX.update(_trackX, elapsed);
            var _changedY:Boolean = _flickY.update(_trackY, elapsed);
            
            if (_changedX || _changedY)
            {
                _drugListener(_trackX, _trackY);
                return false;
            }
            else
                return true;
        }
    }
}