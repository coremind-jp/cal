package jp.coremind.view.implement.starling
{
    import jp.coremind.model.StatusConfigure;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModelConfigure;
    import jp.coremind.model.UpdateRule;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.LayoutCalculator;
    
    import starling.events.Touch;
    import starling.events.TouchEvent;
    
    public class InteractiveElement extends StatefulElement
    {
        override protected function get _statusModelConfigureKey():Class { return InteractiveElement }
        
        StatusModelConfigure.registry(InteractiveElement, [
            new StatusConfigure(StatusGroup.LOCK, UpdateRule.LESS_THAN_PRIORITY, 100, Status.UNLOCK, true, [Status.UNLOCK])
        ]);
        
        protected var
            _touch:Touch;
        
        public function InteractiveElement(
            layoutCalculator:LayoutCalculator,
            controllerClass:Class = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, controllerClass, backgroundBuilder);
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            Log.info("destroy interactive", _touch);
            
            disablePointerDeviceControl();
            
            super.destroy(withReference);
        }
        
        override public function initialize(storageId:String = null):void
        {
            super.initialize(storageId);
            
            enablePointerDeviceControl();
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            controller.pointerDevice.refresh(_reader.id, _elementId);
        }
        
        override public function enablePointerDeviceControl():void
        {
            useHandCursor = touchable = true;
            addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        override public function disablePointerDeviceControl():void
        {
            useHandCursor = touchable = false;
            removeEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        /**
         * フレームワークから発生するタッチイベントのハンドリングを行う.
         */
        protected function _onTouch(e:TouchEvent):void
        {
            _touch = e.getTouch(this);
            
            if (_touch)
            {
                this[_touch.phase]();
                _touch = null;
            }
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
                case StatusGroup.LOCK:
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