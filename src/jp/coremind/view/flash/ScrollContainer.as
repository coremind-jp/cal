package jp.coremind.view.flash
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.data.NumberTracker;
    import jp.coremind.utility.Flick;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.VectorGraphics;
    import jp.coremind.view.IElementContainer;
    
    public class ScrollContainer extends ElementContainer
    {
        private static const _OFFSET:Rectangle = new Rectangle();
        private static const _BEFORE_FLICKAREA_POS:Point = new Point();
        private static const _BEFORE_CONTAINER_POS:Point = new Point();
        private static const _BEFORE_DRUG_SIZE:Point = new Point();
        
        private var
            _listener:Sprite,
            _container:IElementContainer,
            _drugSize:Point,
            _flickArea:Rectangle,
            _flick:Flick;
        
        public function ScrollContainer(
            conatinerClass:Class,
            containerWidth:Number,
            containerHeight:Number,
            absorbThreshold:Number = 0)
        {
            if (0 < containerWidth && 0 < containerHeight)
            {
                var maskShape:Shape = new Shape();
                mask = addChild(maskShape);
                VectorGraphics.rect(maskShape.graphics, containerWidth, containerHeight);
                
                addElement(_container = new conatinerClass());
                
                addChild(_listener = new Sprite()).addEventListener(MouseEvent.MOUSE_DOWN, _onDrug);
                VectorGraphics.rect(_listener.graphics, containerWidth, containerHeight, 0, 0);
                
                _flick = new Flick(absorbThreshold);
                _flickArea = new Rectangle();
                _drugSize = new Point();
            }
        }
        
        public function get contentLayer():IElementContainer
        {
            return _container;
        }
        
        override public function destroy():void
        {
            _listener.removeEventListener(MouseEvent.MOUSE_DOWN, _onDrug);
            _listener = null;
            
            _container.destroy();
            _container = null;
            
            _flick.destory();
            _flick = null;
            
            _flickArea = null;
            _drugSize = null;
            
            super.destroy();
        }
        
        private function _onDrug(e:MouseEvent):void
        {
            _OFFSET.setTo(e.localX, e.localY, mask.width, mask.height);
            
            _updateFlickArea();
            
            _setInitialPosition();
            
            _flick.observe(_onFlickUpdate, _onDrop, _OFFSET, _flickArea);
        }
        
        private function _updateFlickArea():void
        {
            var g:Point = mask.localToGlobal(new Point());
            
            _flickArea.setTo(
                g.x - (_container.width  - mask.width  + _drugSize.x),
                g.y - (_container.height - mask.height + _drugSize.y),
                _container.width,
                _container.height);
        }
        
        private function _setInitialPosition():void
        {
            _BEFORE_CONTAINER_POS.setTo(_container.x, _container.y);
            _BEFORE_FLICKAREA_POS.setTo(_flickArea.x, _flickArea.y);
            _BEFORE_DRUG_SIZE.setTo(_drugSize.x, _drugSize.y);
        }
        
        private function _onFlickUpdate(x:NumberTracker, y:NumberTracker):void
        {
            if (mask.width  < _container.width)
            {
                _drugSize.x  = _BEFORE_DRUG_SIZE.x     + x.totalDelta;
                _container.x = _BEFORE_CONTAINER_POS.x + x.totalDelta;
                _flickArea.x = _BEFORE_FLICKAREA_POS.x - x.totalDelta;
            }
            
            if (mask.height < _container.height)
            {
                _drugSize.y  = _BEFORE_DRUG_SIZE.y     + y.totalDelta;
                _container.y = _BEFORE_CONTAINER_POS.y + y.totalDelta;
                _flickArea.y = _BEFORE_FLICKAREA_POS.y - y.totalDelta;
            }
        }
        
        private function _onDrop(x:NumberTracker, y:NumberTracker):void
        {
        }
        
        private function _drawDrugBox():void
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
        }
    }
}