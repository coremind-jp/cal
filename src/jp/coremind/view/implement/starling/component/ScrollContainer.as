package jp.coremind.view.implement.starling.component
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.component.Slider;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.Container;
    import jp.coremind.view.interaction.Flick;
    import jp.coremind.view.layout.Layout;
    
    import starling.events.Event;
    import starling.events.TouchEvent;
    
    public class ScrollContainer extends Container
    {
        private static const _POINT:Point = new Point();
        private static const _OFFSET:Rectangle = new Rectangle();
        
        private var
            _before:Before,
            _container:IContainer,
            _sliderX:Slider,
            _sliderY:Slider,
            _drugSize:Point,
            _flickArea:Rectangle,
            _flick:Flick;
        
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
        
        public function wrap(element:IContainer):void
        {
            _container = element;
            
            name = _container.name + "ScrollWrapper";
            
            _flick     = new Flick();
            _flickArea = new Rectangle();
            _drugSize  = new Point();
            _before    = new Before();
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            if (_container)
            {
                Log.info("destroy ScrollContainer", withReference);
                
                _container.removeListener(ElementEvent.UPDATE_SIZE, _onUpdateContentSize);
                
                if (withReference)
                {
                    if (_sliderX) _sliderX.destroy(withReference);
                    if (_sliderY) _sliderY.destroy(withReference);
                }
                _container = null;
                _sliderX = _sliderY = null;
                _before = null;
                
                _flick.destory();
            }
            
            super.destroy(withReference);
        }
        
        override protected function _onLoadStorageReader(id:String):void
        {
            super._onLoadStorageReader(id);
            
            /** TODO 設定で変えられるように(clipRectはdrawコールをあげる) */
            //clipRect   = new Rectangle(0, 0, _maxWidth, _maxHeight);
            
            _container.initialize(_maxWidth, _maxHeight, storageId);
            _container.addListener(ElementEvent.UPDATE_SIZE, _onUpdateContentSize);
            _container.x = _container.y = 0;
            addDisplayAt(_container, _background ? 1: 0);
        }
        
        public function get wrappedElement():IElement
        {
            return _container;
        }
        
        public function set sliderX(gauge:Slider):void
        {
            _sliderX = gauge;
            if (_sliderX) _updateSlider();
        }
        
        public function set sliderY(gauge:Slider):void
        {
            _sliderY = gauge;
            if (_sliderY) _updateSlider();
        }
        
        private function _onUpdateContentSize(e:Event):void
        {
            var resultX:Number = _container.x;
            var resultY:Number = _container.y;
            var delta:Number = 0;
            
            var w:Number = _container.x + _container.elementWidth;
            if (w < _maxWidth)
            {
                delta = _maxWidth - w;
                _drugSize.x += delta;
                resultX     += delta;
                
                if (0 < resultX)     resultX = 0;
                if (0 < _drugSize.x) _drugSize.x  = 0;
            }
            
            var h:Number  = _container.y + _container.elementHeight;
            if (h <= _maxHeight)
            {
                delta = _maxHeight - h;
                _drugSize.y += delta;
                resultY     += delta;
                
                if (0 < resultY)     resultY = 0;
                if (0 < _drugSize.y) _drugSize.y  = 0;
            }
            
            if (_container.x != resultX || _container.y != resultY)
                _container.updatePosition(resultX, resultY);
            
            _updateSlider();
        }
        
        private function _updateSlider():void
        {
            if (_sliderX) _sliderX.setRange(_container.elementWidth,  _maxWidth);
            if (_sliderY) _sliderY.setRange(_container.elementHeight, _maxHeight);
            if (_sliderX || _sliderY)
            {
                globalToLocal(new Point(Application.pointerX, Application.pointerY), _POINT);
                
                _OFFSET.setTo(_POINT.x, _POINT.y, _maxWidth, _maxHeight);
                
                _updateFlickArea();
                
                _flick.createTracker(_OFFSET, _flickArea, _onTrackerCreate);
            }
        }
        
        private function _onTrackerCreate(x:NumberTracker, y:NumberTracker):void
        {
            if (_sliderX) _sliderX.update(x.rate);
            if (_sliderY) _sliderY.update(y.rate);
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
        
        override protected function began():void
        {
            globalToLocal(new Point(Application.pointerX, Application.pointerY), _POINT);
            
            _OFFSET.setTo(_POINT.x, _POINT.y, _maxWidth, _maxHeight);
            
            _updateFlickArea();
            
            _setInitialPosition();
            _flick.observe(_OFFSET, _flickArea, _onFlickUpdate);
        }
        
        private function _updateFlickArea():void
        {
            _POINT.setTo(0, 0);
            var g:Point = localToGlobal(_POINT);
            
            _flickArea.setTo(
                g.x - (_container.elementWidth  - _maxWidth  + _drugSize.x),
                g.y - (_container.elementHeight - _maxHeight + _drugSize.y),
                _container.elementWidth,
                _container.elementHeight);
            
            _flickArea.x |= 0;
            _flickArea.y |= 0;
        }
        
        private function _setInitialPosition():void
        {
            _before.containerPosition.setTo(_container.x, _container.y);
            _before.flickAreaPosition.setTo(_flickArea.x, _flickArea.y);
            _before.drugSize.setTo(_drugSize.x, _drugSize.y);
        }
        
        private function _onFlickUpdate(x:NumberTracker, y:NumberTracker):void
        {
            var resultX:Number = _container.x;
            var resultY:Number = _container.y;
            
            if (_maxWidth  < _container.elementWidth)
            {
                _flickArea.x = _before.flickAreaPosition.x - x.totalDelta;
                resultX      = _before.containerPosition.x + x.totalDelta;
                _drugSize.x  = _before.drugSize.x          + x.totalDelta;
                if (_sliderX) _sliderX.update(x.rate);
            }
            
            if (_maxHeight < _container.elementHeight)
            {
                _drugSize.y  = _before.drugSize.y          + y.totalDelta;
                resultY      = _before.containerPosition.y + y.totalDelta;
                _flickArea.y = _before.flickAreaPosition.y - y.totalDelta;
                if (_sliderY) _sliderY.update(y.rate);
            }
            
            _container.updatePosition(resultX, resultY);
        }
    }
}

import flash.geom.Point;

class Before
{
    public var
        flickAreaPosition:Point,
        containerPosition:Point,
        drugSize:Point;
    
    public function Before()
    {
        flickAreaPosition = new Point();
        containerPosition = new Point();
        drugSize = new Point();
    }
}