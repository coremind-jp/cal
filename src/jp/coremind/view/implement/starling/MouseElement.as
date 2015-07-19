package jp.coremind.view.implement.starling
{
    import jp.coremind.configure.StatusConfigure;
    import jp.coremind.configure.UpdateRule;
    import jp.coremind.utility.MultistageStatus;
    import jp.coremind.utility.Status;
    
    import starling.events.TouchEvent;

    public class MouseElement extends TouchElement
    {
        public static const CONFIG_LIST:Array = MultistageStatus.margePriorityList(
            InteractiveElement.CONFIG_LIST,
            new StatusConfigure(GROUP_PRESS, UpdateRule.LESS_THAN_PRIORITY, 25, Status.UP, false, [Status.CLICK, Status.UP]),
            new StatusConfigure(GROUP_RELEASE, UpdateRule.ALWAYS, 0, Status.ROLL_OUT, true)
        );
        
        private var
            _bHitTest:Boolean,
            _bHover:Boolean;
        
        public function MouseElement(inflateSize:Number = 6, multistageStatusConfig:Array = null)
        {
            super(inflateSize, multistageStatusConfig || CONFIG_LIST);
            
            _bHover = false;
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            _updateStatus(GROUP_RELEASE, Status.ROLL_OUT);
        }
        
        override protected function _onTouch(e:TouchEvent):void
        {
            _touch = e.getTouch(this);
            
            if (!_touch)
            {
                if (_bHover) _updateStatus(GROUP_RELEASE, Status.ROLL_OUT);
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
            _updateStatus(GROUP_RELEASE, Status.ROLL_OVER);
        }
        
        override protected function began():void
        {
            _triggerRect.x = _touch.globalX - (_triggerRect.width  >> 1);
            _triggerRect.y = _touch.globalY - (_triggerRect.height >> 1);
            
            _bHitTest = _hold = true;
            _updateStatus(GROUP_PRESS, Status.DOWN);
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
                _updateStatus(GROUP_PRESS, Status.DOWN):
                _updateStatus(GROUP_PRESS, isRollOver ? Status.ROLL_OVER: Status.ROLL_OUT);
        }
        
        override protected function ended():void
        {
            var isRollOver:Boolean = _bHitTest && !_hold;
            var isClick:Boolean    = _bHitTest &&  _hold;
            
            _bHover = isRollOver;
            
            if (isClick)
            {
                _updateStatus(GROUP_RELEASE, Status.ROLL_OVER);
                _updateStatus(GROUP_PRESS, Status.CLICK);
            }
            else
            {
                _updateStatus(GROUP_RELEASE, isRollOver ? Status.ROLL_OVER: Status.ROLL_OUT);
                _updateStatus(GROUP_PRESS, Status.UP);
            }
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case GROUP_RELEASE:
                    switch(status)
                    {
                        case Status.ROLL_OVER: _onRollOver(); return true;
                        case Status.ROLL_OUT : _onRollOut(); return true;
                    }
                    break;
                
                case GROUP_PRESS:
                    switch(status)
                    {
                        case Status.ROLL_OVER: _onRollOver(); return true;
                        case Status.ROLL_OUT : _onRollOut(); return true;
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