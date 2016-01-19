package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.core.StatusModelType;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModule;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.Layout;
    
    import starling.events.TouchEvent;
    
    public class MouseElement extends TouchElement
    {
        private var
            _bHitTest:Boolean,
            _bHover:Boolean;
        
        public function MouseElement(layoutCalculator:Layout, backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            
            _bHover = false;
            button = true;
        }
        
        override protected function get statusModelType():String
        {
            return StatusModelType.MOUSE_ELEMENT;
        }
        
        override protected function _onTouch(e:TouchEvent):void
        {
            e.stopPropagation();
            
            _touch = e.getTouch(this);
            
            if (!_touch)
            {
                if (_bHover)
                    _info.modules.getModule(StatusModule).update(StatusGroup.RELEASE, Status.ROLL_OUT);
                _bHover = false;
            }
            else
            if (this[_touch.phase] is Function)
            {
                this[_touch.phase]();
                _touch = null;
            }
        }
        
        override protected function hover():void
        {
            if (_bHover) return;
            
            _bHover = true;
            _info.modules.getModule(StatusModule).update(StatusGroup.RELEASE, Status.ROLL_OVER);
        }
        
        override protected function began():void
        {
            _triggerRect.x = _touch.globalX - (_triggerRect.width  >> 1);
            _triggerRect.y = _touch.globalY - (_triggerRect.height >> 1);
            
            _bHitTest = _hold = true;
            _info.modules.getModule(StatusModule).update(StatusGroup.PRESS, Status.DOWN);
        }
        
        override protected function moved():void
        {
            _POINTER_RECT.x = _touch.globalX;
            _POINTER_RECT.y = _touch.globalY;
            
            _bHitTest = hitTest(_touch.getLocation(this), true);
            _hold     = _triggerRect.intersects(_POINTER_RECT);
            
            var isRollOver:Boolean = _bHitTest && !_hold;
            var isClick:Boolean    = _bHitTest &&  _hold;
            var status:StatusModule = _info.modules.getModule(StatusModule) as StatusModule;
            
            isClick ?
                status.update(StatusGroup.PRESS, Status.DOWN):
                isRollOver ?
                    status.update(StatusGroup.RELEASE, Status.ROLL_OVER):
                    status.update(StatusGroup.RELEASE, Status.ROLL_OUT);
        }
        
        override protected function ended():void
        {
            var isRollOver:Boolean = _bHitTest && !_hold;
            var isClick:Boolean    = _bHitTest &&  _hold;
            var status:StatusModule = _info.modules.getModule(StatusModule) as StatusModule;
            
            _bHover = isRollOver;
            if (isClick)
            {
                status.update(StatusGroup.PRESS, Status.CLICK);
                
                //↑のactionメソッドでViewの移動が発生してこの要素が破棄されていた場合_readerがnullになる可能性があるので、
                //そのチェックをしてからボタンコントローラーへメッセージを送る
                if (_reader)
                    Application.sync.isRunning() ?
                        status.update(StatusGroup.RELEASE, Status.ROLL_OUT):
                        status.update(StatusGroup.RELEASE, Status.ROLL_OVER);
            }
            else
            {
                isRollOver ?
                    status.update(StatusGroup.RELEASE, Status.ROLL_OVER):
                    status.update(StatusGroup.RELEASE, Status.ROLL_OUT);
                status.update(StatusGroup.PRESS, Status.UP);
            }
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case StatusGroup.RELEASE:
                    switch(status)
                    {
                        case Status.ROLL_OVER:
                            _onRollOver();
                            Application.router.notify(_info, group, status);
                            return true;
                            
                        case Status.ROLL_OUT:
                            _onRollOut();
                            Application.router.notify(_info, group, status);
                            return true;
                    }
                    break;
                
                case StatusGroup.PRESS:
                    switch(status)
                    {
                        case Status.ROLL_OVER:
                            _onRollOver();
                            Application.router.notify(_info, group, status);
                            return true;
                            
                        case Status.ROLL_OUT:
                            _onRollOut();
                            Application.router.notify(_info, group, status);
                            return true;
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