package jp.coremind.view.layout
{
    import flash.geom.Point;
    
    import jp.coremind.core.Direction;

    public class GlidLayout implements ILayout
    {
        private var
            _variableDirection:String,
            _marginX:int,
            _marginY:int,
            _stack:int,
            _point:Point;
        
        public function GlidLayout(
            variableDirection:String,
            marginX:int = 0,
            marginY:int = 0,
            stack:int = 1,
            point:Point = null)
        {
            _variableDirection = variableDirection;
            _marginX = marginX;
            _marginY = marginY;
            _stack = stack < 1 ? 1: stack;
            _point = point;
        }
        
        public function calcPosition(width:Number, height:Number, index:int, length:int = 0):Point
        {
            var iValiable:int = index / _stack;
            var iFixed:int    = index % _stack;
            var p:Point       = _point || new Point();
            
            if (_variableDirection == Direction.X)
            {
                p.x = (width  + _marginX) * iValiable;
                p.y = (height + _marginY) * iFixed;
            }
            else
            {
                p.x = (width  + _marginX) * iFixed;
                p.y = (height + _marginY) * iValiable;
            }
            
            return p;
        }
        
        public function calcSize(width:Number, height:Number, index:int, length:int = 0):Point
        {
            var iValiable:int = index / _stack;
            var iFixed:int    = 1 <= iValiable ? (_stack - 1) % _stack: index % _stack;
            var p:Point       = _point || new Point();
            
            if (_variableDirection == Direction.X)
            {
                p.x = (width  + _marginX) * iValiable + width;
                p.y = (height + _marginY) * _stack    + height;
            }
            else
            {
                p.x = (width  + _marginX) * iFixed    + width;
                p.y = (height + _marginY) * iValiable + height;
            }
            
            return p;
        }
    }
}