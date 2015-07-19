package jp.coremind.view.implement.starling
{
    import jp.coremind.configure.StatusConfigure;
    import jp.coremind.configure.UpdateRule;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.utility.Status;
    import jp.coremind.view.abstract.IInteractiveElement;
    
    import starling.events.Touch;
    import starling.events.TouchEvent;
    
    public class InteractiveElement extends StatefulElement implements IInteractiveElement
    {
        public static const GROUP_LOCK:String = "groupLock";
        public static const CONFIG_LIST:Array = [
            new StatusConfigure(GROUP_LOCK, UpdateRule.LESS_THAN_PRIORITY, 100, Status.UNLOCK, true, [Status.UNLOCK])
        ];
        
        protected var
            _touch:Touch;
        
        public function InteractiveElement(multistageStatusConfig:Array = null)
        {
            super(multistageStatusConfig || CONFIG_LIST);
        }
        
        override public function destroy():void
        {
            _touch = null;
            
            disablePointerDeviceControl();
            
            super.destroy();
        }
        
        override public function initialize(storage:StorageAccessor):void
        {
            super.initialize(storage);
            
            enablePointerDeviceControl();
        }
        
        override public function reuseInstance():void
        {
            super.reuseInstance();
            
            _initializeStatus();
        }
        
        override public function resetInstance():void
        {
            super.resetInstance();
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            enable();
        }
        
        public function isEnable():Boolean
        {
            return !_status.equalGroup(GROUP_LOCK) || _status.equal(Status.UNLOCK);
        }
        
        public function toggleEnable():void
        {
            isEnable() ? disable(): enable();
        }
        
        override public function enablePointerDeviceControl():void
        {
            useHandCursor = touchable = true;
            addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        public function enable():void
        {
            _updateStatus(GROUP_LOCK, Status.UNLOCK);
        }
        
        override public function disablePointerDeviceControl():void
        {
            useHandCursor = touchable = false;
            removeEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        public function disable():void
        {
            _updateStatus(GROUP_LOCK, Status.LOCK);
        }
        
        /**
         * フレームワークから発生するタッチイベントのハンドリングを行う.
         */
        protected function _onTouch(e:TouchEvent):void
        {
            _touch = e.getTouch(this);
            if (_touch) this[_touch.phase]();
        }
        
        /** TouchPhase.HOVERハンドリング */
        protected function hover():void {}
        
        /** TouchPhase.BEGANハンドリング */
        protected function began():void　{}
        
        /** TouchPhase.MOVEDハンドリング */
        protected function moved():void　{}
        
        /** TouchPhase.STATIONARYハンドリング */
        protected function stationary():void {}
        
        /** TouchPhase.ENDEDハンドリング */
        protected function ended():void　{}
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case GROUP_LOCK:
                    switch(status)
                    {
                        case Status.UNLOCK: _onEnable(); return true;
                        case Status.LOCK  : _onDisable(); return true;
                    }
                    break;
            }
            
            return super._applyStatus(group, status);
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.UNLOCK
         */
        protected function _onEnable():void
        {
            //Log.info("_onEnable");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.LOCK
         */
        protected function _onDisable():void
        {
            //Log.info("_onDisable");
        }
    }
}