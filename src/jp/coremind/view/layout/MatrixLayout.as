package jp.coremind.view.layout
{
    import flash.geom.Point;

    public class MatrixLayout implements ILayout
    {
        public static const VARIABLE_DIRECTION_X:String = "variableDirectionX";
        public static const VARIABLE_DIRECTION_Y:String = "variableDirectionY";
        
        private var
            _variableDirection:String,
            _marginX:int,
            _marginY:int,
            _stack:int,
            _point:Point;
        
        public function MatrixLayout(
            variableDirection:String = "x",
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
            
            if (_variableDirection == VARIABLE_DIRECTION_Y)
            {
                p.x = (width  + _marginX) * iFixed;
                p.y = (height + _marginY) * iValiable;
            }
            else
            {
                p.x = (width  + _marginX) * iValiable;
                p.y = (height + _marginY) * iFixed;
            }
            
            return p;
        }
    }
}