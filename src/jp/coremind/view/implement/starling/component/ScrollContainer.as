package jp.coremind.view.implement.starling.component
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.data.NumberTracker;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.view.abstract.IElementContainer;
    import jp.coremind.view.implement.starling.ElementContainer;
    import jp.coremind.view.transition.Flick;
    
    import starling.events.Event;
    import starling.events.Touch;
    import jp.coremind.view.abstract.component.Slider;
    
    public class ScrollContainer extends ElementContainer
    {
        private static const _POINT:Point = new Point();
        private static const _OFFSET:Rectangle = new Rectangle();
        private static const _BEFORE_FLICKAREA_POS:Point = new Point();
        private static const _BEFORE_CONTAINER_POS:Point = new Point();
        private static const _BEFORE_DRUG_SIZE:Point = new Point();
        
        private var
            _container:IElementContainer,
            _sliderX:Slider,
            _sliderY:Slider,
            _drugSize:Point,
            _flickArea:Rectangle,
            _flick:Flick;
        
        public function ScrollContainer(
            conatiner:IElementContainer,
            containerWidth:Number,
            containerHeight:Number)
        {
            addElement(_container = conatiner);
            _container.addListener(ElementEvent.UPDATE_SIZE, _onUpdateContentSize);
            
            if (0 < containerWidth && 0 < containerHeight)
            {
                clipRect   = new Rectangle(0, 0, containerWidth, containerHeight);
                
                _flick     = new Flick();
                _flickArea = new Rectangle();
                _drugSize  = new Point();
            }
            else
                disablePointerDeviceControl();
        }
        
        override public function destroy():void
        {
            _container = null;
            _sliderX = _sliderY = null;
            
            if (_flick)
                _flick.destory();
            
            super.destroy();
        }
        
        public function get contentLayer():IElementContainer
        {
            return _container;
        }
        
        public function set sliderX(gauge:Slider):void
        {
            _sliderX = gauge;
            _updateSlider();
        }
        
        public function set sliderY(gauge:Slider):void
        {
            _sliderY = gauge;
            _updateSlider();
        }
        
        private function _onUpdateContentSize(e:Event):void
        {
            var delta:Number = 0;
            
            var w:Number = _container.x + _container.elementWidth;
            if (w < clipRect.width)
            {
                delta = clipRect.width - w;
                _drugSize.x  += delta;
                _container.x += delta;
                
                if (0 < _container.x) _container.x = 0;
                if (0 < _drugSize.x)  _drugSize.x  = 0;
            }
            
            var h:Number  = _container.y + _container.elementHeight;
            if (h <= clipRect.height)
            {
                delta = clipRect.height - h;
                _drugSize.y  += delta;
                _container.y += delta;
                
                if (0 < _container.y) _container.y = 0;
                if (0 < _drugSize.y)  _drugSize.y  = 0;
            }
            
            _container.refresh();
            _updateSlider();
        }
        
        private function _updateSlider():void
        {
            if (_sliderX) _sliderX.setRange(_container.elementWidth,  clipRect.width);
            if (_sliderY) _sliderY.setRange(_container.elementHeight, clipRect.height);
            if (_sliderX || _sliderY)
            {
                globalToLocal(new Point(Application.stage.mouseX, Application.stage.mouseY), _POINT);
                
                _OFFSET.setTo(_POINT.x, _POINT.y, clipRect.width, clipRect.height);
                
                _updateFlickArea();
                
                _flick.createTracker(_OFFSET, _flickArea, _onTrackerCreate);
            }
        }
        
        private function _onTrackerCreate(x:NumberTracker, y:NumberTracker):void
        {
            if (_sliderX) _sliderX.update(x.rate);
            if (_sliderY) _sliderY.update(y.rate);
        }
        
        override protected function _onDown(t:Touch):void
        {
            globalToLocal(new Point(Application.stage.mouseX, Application.stage.mouseY), _POINT);
            
            _OFFSET.setTo(_POINT.x, _POINT.y, clipRect.width, clipRect.height);
            
            _updateFlickArea();
            
            _setInitialPosition();
            _flick.observe(_OFFSET, _flickArea, _onFlickUpdate);
        }
        
        private function _updateFlickArea():void
        {
            _POINT.setTo(0, 0);
            var g:Point = localToGlobal(_POINT);
            
            _flickArea.setTo(
                g.x - (_container.elementWidth  - clipRect.width  + _drugSize.x),
                g.y - (_container.elementHeight - clipRect.height + _drugSize.y),
                _container.elementWidth,
                _container.elementHeight);
        }
        
        private function _setInitialPosition():void
        {
            _BEFORE_CONTAINER_POS.setTo(_container.x, _container.y);
            _BEFORE_FLICKAREA_POS.setTo(_flickArea.x, _flickArea.y);
            _BEFORE_DRUG_SIZE.setTo(_drugSize.x, _drugSize.y);
        }
        
        private function _onFlickUpdate(x:NumberTracker, y:NumberTracker):void
        {
            if (clipRect.width  < _container.elementWidth)
            {
                _drugSize.x  = _BEFORE_DRUG_SIZE.x     + x.totalDelta;
                _container.x = _BEFORE_CONTAINER_POS.x + x.totalDelta;
                _flickArea.x = _BEFORE_FLICKAREA_POS.x - x.totalDelta;
                if (_sliderX) _sliderX.update(x.rate);
            }
            
            if (clipRect.height < _container.elementHeight)
            {
                _drugSize.y  = _BEFORE_DRUG_SIZE.y     + y.totalDelta;
                _container.y = _BEFORE_CONTAINER_POS.y + y.totalDelta;
                _flickArea.y = _BEFORE_FLICKAREA_POS.y - y.totalDelta;
                if (_sliderY) _sliderY.update(y.rate);
            }
            
            _container.refresh();
        }
    }
}