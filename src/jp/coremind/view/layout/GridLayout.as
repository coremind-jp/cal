package jp.coremind.view.layout
{
    import flash.geom.Rectangle;
    

    public class GridLayout extends FixedElementClassLayout implements ILayout
    {
        private var
            _variableDirection:String,
            _marginX:int,
            _marginY:int,
            _stack:int;
        
        public function GridLayout(
            elementClass:Class,
            variableDirection:String,
            marginX:int = 0,
            marginY:int = 0,
            stack:int = 1,
            temporaryRect:Rectangle = null)
        {
            super(elementClass, temporaryRect);
            
            _variableDirection = variableDirection;
            _marginX = marginX;
            _marginY = marginY;
            _stack = stack < 1 ? 1: stack;
        }
        
        public function calcElementRect(
            parentWidth:Number,
            parentHeight:Number,
            index:int,
            length:int = 0):Rectangle
        {
            var iValiable:int = index / _stack;
            var iFixed:int    = index % _stack;
            var r:Rectangle   = _rect || new Rectangle();
            
            _variableDirection == Direction.X ?
                
                r.setTo(
                    (_elementWidth  + _marginX) * iValiable,
                    (_elementHeight + _marginY) * iFixed,
                    _elementWidth, _elementHeight):
                
                r.setTo(
                    (_elementWidth  + _marginX) * iFixed,
                    (_elementHeight + _marginY) * iValiable,
                    _elementWidth, _elementHeight);
            
            return r;
        }
        
        public function calcTotalRect(
            parentWidth:Number,
            parentHeight:Number,
            index:int,
            length:int = 0):Rectangle
        {
            var iValiable:int = index / _stack;
            var iFixed:int    = 1 <= iValiable ? (_stack - 1) % _stack: index % _stack;
            var r:Rectangle   = _rect || new Rectangle();
            
            r.setEmpty();
            if (_variableDirection == Direction.X)
            {
                r.width  = (_elementWidth  + _marginX) * iValiable + _elementWidth;
                r.height = (_elementHeight + _marginY) * _stack    + _elementHeight;
            }
            else
            {
                r.width  = (_elementWidth  + _marginX) * iFixed    + _elementWidth;
                r.height = (_elementHeight + _marginY) * iValiable + _elementHeight;
            }
            
            return r;
        }
    }
}