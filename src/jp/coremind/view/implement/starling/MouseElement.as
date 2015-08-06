package jp.coremind.view.implement.starling
{
    import jp.coremind.model.StatusModelConfigure;
    import jp.coremind.model.StatusConfigure;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.UpdateRule;
    import jp.coremind.utility.data.Status;
    
    import starling.events.TouchEvent;

    public class MouseElement extends TouchElement
    {
        override protected function get _statusModelConfigureKey():Class { return MouseElement }
        
        StatusModelConfigure.registry(
            MouseElement,
            StatusModelConfigure.marge(
                InteractiveElement,
                    new StatusConfigure(StatusGroup.PRESS,   UpdateRule.LESS_THAN_PRIORITY, 75, Status.UP, false, [Status.CLICK, Status.UP]),
                    new StatusConfigure(StatusGroup.RELEASE, UpdateRule.ALWAYS, 25, Status.ROLL_OUT, true)
                ));
        
        private var
            _bHitTest:Boolean,
            _bHover:Boolean;
        
        public function MouseElement(inflateSize:Number = 6)
        {
            super(inflateSize);
            
            _bHover = false;
        }
        
        override protected function _onTouch(e:TouchEvent):void
        {
            _touch = e.getTouch(this);
            
            if (!_touch)
            {
                if (_bHover) controller.button.rollOut(_reader.id);
                _bHover = false;
            }
            else
            if (this[_touch.phase] is Function)
                this[_touch.phase]();
        }
        
        override protected function hover():void
        {
            if (_bHover) return;
            
            _bHover = true;
            controller.button.rollOver(_reader.id);
        }
        
        override protected function began():void
        {
            _triggerRect.x = _touch.globalX - (_triggerRect.width  >> 1);
            _triggerRect.y = _touch.globalY - (_triggerRect.height >> 1);
            
            _bHitTest = _hold = true;
            controller.button.press(_reader.id);
        }
        
        override protected function moved():void
        {
            _POINTER_RECT.x = _touch.globalX;
            _POINTER_RECT.y = _touch.globalY;
            
            _bHitTest = hitTest(_touch.getLocation(this), true);
            _hold     = _triggerRect.intersects(_POINTER_RECT);
            
            var isRollOver:Boolean = _bHitTest && !_hold;
            var isClick:Boolean    = _bHitTest &&  _hold;
            
            isClick ?
                controller.button.press(_reader.id):
                isRollOver ?
                    controller.button.rollOver(_reader.id):
                    controller.button.rollOut(_reader.id);
        }
        
        override protected function ended():void
        {
            var isRollOver:Boolean = _bHitTest && !_hold;
            var isClick:Boolean    = _bHitTest &&  _hold;
            
            _bHover = isRollOver;
            
            if (isClick)
            {
                controller.button.rollOver(_reader.id);
                controller.action(_reader.id);
            }
            else
            {
                isRollOver ?
                    controller.button.rollOver(_reader.id):
                    controller.button.rollOut(_reader.id);
                controller.button.release(_reader.id);
            }
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case StatusGroup.RELEASE:
                    switch(status)
                    {
                        case Status.ROLL_OVER: _onRollOver(); return true;
                        case Status.ROLL_OUT :  _onRollOut(); return true;
                    }
                    break;
                
                case StatusGroup.PRESS:
                    switch(status)
                    {
                        case Status.ROLL_OVER: _onRollOver(); return true;
                        case Status.ROLL_OUT :  _onRollOut(); return true;
                    }
                    break;
            }
            
            return super._applyStatus(group, status);
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.ROLL_OVER
         */
        protected function _onRollOver():void
        {
            //Log.info("_onRollOver");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.ROLL_OUT
         */
        protected function _onRollOut():void
        {
            //Log.info("_onRollOut");
        }
    }
}