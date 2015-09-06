package jp.coremind.view.implement.starling.component
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IElementContainer;
    import jp.coremind.view.abstract.component.Slider;
    import jp.coremind.view.implement.starling.ElementContainer;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.LayoutCalculator;
    import jp.coremind.view.transition.Flick;
    
    import starling.events.Event;
    
    public class ScrollContainer extends ElementContainer
    {
        private static const _POINT:Point = new Point();
        private static const _OFFSET:Rectangle = new Rectangle();
        
        private var
            _before:Before,
            _container:IElementContainer,
            _sliderX:Slider,
            _sliderY:Slider,
            _drugSize:Point,
            _flickArea:Rectangle,
            _flick:Flick;
        
        /**
         * 任意の表示オブジェクトをスクロールさせるクラス.
         */
        public function ScrollContainer(
            layoutCalculator:LayoutCalculator,
            controllerClass:Class = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, controllerClass, backgroundBuilder);
            
            disablePointerDeviceControl();
        }
        
        public function wrap(element:IElement):void
        {
            _container = element as IElementContainer;
            
            if (_container)
            {
                _container.addListener(ElementEvent.UPDATE_SIZE, _onUpdateContentSize);
                
                addElement(_container);
                
                name       = _container.name + "ScrollWrapper";
                /** TODO 設定で変えられるように(clipRectはdrawコールをあげる) */
                //clipRect   = new Rectangle(0, 0, _maxWidth, _maxHeight);
                _flick     = new Flick();
                _flickArea = new Rectangle();
                _drugSize  = new Point();
                _before    = new Before();
                initialize(null);
            }
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            Log.info("destroy scroll", withReference, _container);
            if (_container)
            {
                _container.removeListener(ElementEvent.UPDATE_SIZE, _onUpdateContentSize);
                
                if (withReference)
                {
                    _container.destroy(withReference);
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
        
        override public function initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            super.initializeElementSize(actualParentWidth, actualParentHeight)
            _container.initializeElementSize(actualParentWidth, actualParentHeight);
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
            var delta:Number = 0;
            
            var w:Number = _container.x + _container.elementWidth;
            if (w < _maxWidth)
            {
                delta = _maxWidth - w;
                _drugSize.x  += delta;
                _container.x += delta;
                
                if (0 < _container.x) _container.x = 0;
                if (0 < _drugSize.x)  _drugSize.x  = 0;
            }
            
            var h:Number  = _container.y + _container.elementHeight;
            if (h <= _maxHeight)
            {
                delta = _maxHeight - h;
                _drugSize.y  += delta;
                _container.y += delta;
                
                if (0 < _container.y) _container.y = 0;
                if (0 < _drugSize.y)  _drugSize.y  = 0;
            }
            
            _container.refreshChildrenLayout();
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
            if (_maxWidth  < _container.elementWidth)
            {
                _drugSize.x  = _before.drugSize.x          + x.totalDelta;
                _container.x = _before.containerPosition.x + x.totalDelta;
                _flickArea.x = _before.flickAreaPosition.x - x.totalDelta;
                if (_sliderX) _sliderX.update(x.rate);
            }
            
            if (_maxHeight < _container.elementHeight)
            {
                _drugSize.y  = _before.drugSize.y          + y.totalDelta;
                _container.y = _before.containerPosition.y + y.totalDelta;
                _flickArea.y = _before.flickAreaPosition.y - y.totalDelta;
                if (_sliderY) _sliderY.update(y.rate);
            }
            
            _container.refreshChildrenLayout();
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