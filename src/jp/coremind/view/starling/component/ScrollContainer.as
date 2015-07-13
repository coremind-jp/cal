package jp.coremind.view.starling.component
{
    import flash.display.Shape;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.data.NumberTracker;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.utility.Flick;
    import jp.coremind.view.IElementContainer;
    
    import starling.events.Event;
    import starling.events.Touch;
    import jp.coremind.view.starling.ElementContainer;
    
    public class ScrollContainer extends ElementContainer
    {
        private static const _POINT:Point = new Point();
        private static const _OFFSET:Rectangle = new Rectangle();
        private static const _BEFORE_FLICKAREA_POS:Point = new Point();
        private static const _BEFORE_CONTAINER_POS:Point = new Point();
        private static const _BEFORE_DRUG_SIZE:Point = new Point();
        
        private var
            _container:IElementContainer,
            _drugSize:Point,
            _flickArea:Rectangle,
            _flick:Flick;
        
        public function ScrollContainer(
            conatiner:IElementContainer,
            containerWidth:Number,
            containerHeight:Number,
            absorbThreshold:Number = 0)
        {
            if (0 < containerWidth && 0 < containerHeight)
            {
                addElement(_container = conatiner);
                _container.addListener(ElementEvent.UPDATE_SIZE, _onUpdateElementSize);
                
                _flick     = new Flick(absorbThreshold);
                _flickArea = new Rectangle();
                _drugSize  = new Point();
                clipRect   = new Rectangle(0, 0, containerWidth, containerHeight);
            }
        }
        
        private function _onUpdateElementSize(e:Event):void
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
        }
        
        public function get contentLayer():IElementContainer
        {
            return _container;
        }
        
        override public function destroy():void
        {
            _container = null;
            
            if (_flick)
                _flick.destory();
            
            super.destroy();
        }
        
        override protected function _onDown(t:Touch):void
        {
            globalToLocal(new Point(Application.stage.mouseX, Application.stage.mouseY), _POINT);
            
            _OFFSET.setTo(_POINT.x, _POINT.y, clipRect.width, clipRect.height);
            
            _updateFlickArea();
            
            _setInitialPosition();
            
            _flick.observe(_onFlickUpdate, _onDrop, _OFFSET, _flickArea);
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
            }
            
            if (clipRect.height < _container.elementHeight)
            {
                _drugSize.y  = _BEFORE_DRUG_SIZE.y     + y.totalDelta;
                _container.y = _BEFORE_CONTAINER_POS.y + y.totalDelta;
                _flickArea.y = _BEFORE_FLICKAREA_POS.y - y.totalDelta;
            }
            
            _container.refresh();
        }
        
        private function _onDrop(x:NumberTracker, y:NumberTracker):void {}
        
        private function _drawDrugBox(_x:NumberTracker, _y:NumberTracker):void
        {
            var s:Shape = Application.debugShape;
            
            s.graphics.clear();
            s.graphics.beginFill(0, 0);
            s.graphics.lineStyle(1, 0);
            s.graphics.drawRect(
                _flickArea.left,
                _flickArea.top,
                _flickArea.width,
                _flickArea.height);
            s.graphics.endFill();
            
            s.graphics.beginFill(0xFF0000, 0.5);
            s.graphics.lineStyle(1, 0);
            s.graphics.drawRect(
                _flickArea.left + _OFFSET.x,
                _flickArea.top  + _OFFSET.y,
                _flickArea.right  - (_OFFSET.width  - _OFFSET.x),
                _flickArea.bottom - (_OFFSET.height - _OFFSET.y));
            s.graphics.endFill();
            
            s.graphics.beginFill(0x0000FF, 0.5);
            s.graphics.lineStyle(1, 0);
            s.graphics.drawRect(
                _x.min,
                _y.min,
                _x.max,
                _y.max);
            s.graphics.endFill();
        }
    }
}