package jp.coremind.view.layout
{
    import flash.geom.Rectangle;
    
    import jp.coremind.view.abstract.IBox;

    public class LayoutCalculator
    {
        private var
            _width:Size,
            _height:Size,
            _horizontalAlign:Align,
            _verticalAlign:Align;
        
        public function LayoutCalculator(
            width:Size = null,
            height:Size = null,
            horizontalAlign:Align = null,
            verticalAlign:Align = null)
        {
            _width  = width  || Size.PARENT_EQUAL;
            _height = height || Size.PARENT_EQUAL;
            _horizontalAlign = horizontalAlign || Align.LEFT;
            _verticalAlign   = verticalAlign   || Align.TOP;
        }
        
        public function destroy():void
        {
            _width = _height = null;
            _horizontalAlign = _verticalAlign = null;
        }
        
        public function applyDisplayObject(displayObject:IBox, actualParentWidth:int, actualParentHeight:int):void
        {
            displayObject.width  = _width.calc(actualParentWidth);
            displayObject.height = _height.calc(actualParentHeight);
            displayObject.x      = _horizontalAlign.calc(actualParentWidth, displayObject.width);
            displayObject.y      = _verticalAlign.calc(actualParentHeight, displayObject.height);
        }
        
        public function exportRectangle(
            actualParentWidth:int,
            actualParentHeight:int,
            rect:Rectangle):Rectangle
        {
            rect = rect || new Rectangle();
            
            var w:Number = _width.calc(actualParentWidth);
            var h:Number = _height.calc(actualParentHeight);
            
            rect.setTo(_horizontalAlign.calc(actualParentWidth, w), _verticalAlign.calc(actualParentHeight, h), w, h);
            
            return rect;
        }
        
        public function get width():Size
        {
            return _width;
        }

        public function get height():Size
        {
            return _height;
        }

        public function get horizontalAlign():Align
        {
            return _horizontalAlign;
        }

        public function get verticalAlign():Align
        {
            return _verticalAlign;
        }
    }
}