package jp.coremind.view.implement.starling.component
{
    import jp.coremind.event.ElementEvent;
    import jp.coremind.model.module.ScrollModule;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.component.Slider;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.ContainerWrapper;
    import jp.coremind.view.layout.Layout;
    
    import starling.events.Event;
    import starling.events.TouchEvent;
    
    public class ScrollContainer extends ContainerWrapper
    {
        private var
            _sliderX:Slider,
            _sliderY:Slider;
        
        /**
         * 任意の表示オブジェクトをスクロールさせるクラス.
         */
        public function ScrollContainer(
            layoutCalculator:Layout,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            touchHandling = true;
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            Log.info("destroy ScrollContainer", withReference);
            
            scrollModule.removeListener(_onScroll);
            
            if (_wrappedContainer)
                _wrappedContainer.removeListener(ElementEvent.UPDATE_SIZE, _updateSlider);
            
            if (withReference)
            {
                if (_sliderX) _sliderX.destroy(withReference);
                if (_sliderY) _sliderY.destroy(withReference);
            }
            _sliderX = _sliderY = null;
            
            super.destroy(withReference);
        }
        
        private function get scrollModule():ScrollModule
        {
            return _wrappedContainer.elementInfo.elementModel.getModule(ScrollModule) as ScrollModule;
        }
        
        public function set sliderX(gauge:Slider):void { _sliderX = gauge; }
        public function set sliderY(gauge:Slider):void { _sliderY = gauge; }
        
        override protected function _onLoadElementInfo():void
        {
            super._onLoadElementInfo();
            
            _wrappedContainer.initialize(_maxWidth, _maxHeight, _reader.id);
            _wrappedContainer.addListener(ElementEvent.UPDATE_SIZE, _updateSlider);
            _wrappedContainer.addListener(ElementEvent.READY, _onLoadWrappedContainer);
            
            addDisplayAt(_wrappedContainer, _background ? 1: 0);
        }
        
        private function _onLoadWrappedContainer(e:Event):void
        {
            _wrappedContainer.removeListener(ElementEvent.READY, _onLoadWrappedContainer);
            
            _updateSlider();
            scrollModule.addListener(_onScroll);
        }
        
        private function _updateSlider(e:Event = null):void
        {
            if (_sliderX) _sliderX.setRange(_wrappedContainer.elementWidth,  _maxWidth);
            if (_sliderY) _sliderY.setRange(_wrappedContainer.elementHeight, _maxHeight);
            if (_sliderX || _sliderY) scrollModule.createTracker(_onScroll);
        }
        
        private function _onScroll(x:NumberTracker, y:NumberTracker):void
        {
            if (_sliderX && x) _sliderX.update(x.rate);
            if (_sliderY && y) _sliderY.update(y.rate);
        }
        
        //このクラスインスタンスのTouchハンドラは開始だけ取得できれば良いので既存の実装を継承させない.
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
        
        override protected function began():void
        {
            scrollModule.beginPointerDeviceListening();
        }
    }
}