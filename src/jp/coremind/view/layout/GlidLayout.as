package jp.coremind.view.layout
{
    import flash.geom.Point;
    
    import jp.coremind.utility.Log;

    public class GlidLayout implements ILayout
    {
        public static const VARIABLE_DIRECTION_X:String = "variableDirectionX";
        public static const VARIABLE_DIRECTION_Y:String = "variableDirectionY";
        
        private var
            _variableDirection:String,
            _visibleNumChildren:int,
            _marginX:int,
            _marginY:int,
            _stack:int,
            _point:Point;
        
        public function GlidLayout(
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
        
        public function get visibleNumChildren():int
        {
            return _visibleNumChildren;
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
        
        public function updateVisibleNumChildren(elementWidth:Number, elementHeight:Number, clipW:Number, clipH:Number):void
        {
            _visibleNumChildren = 0;
            var p:Point;
            
            if (_variableDirection == VARIABLE_DIRECTION_X)
            {
                while (true)
                {
                    p = calcPosition(elementWidth, elementHeight, _visibleNumChildren);
                    if (clipW < p.x + elementWidth) break;
                    else _visibleNumChildren++;
                }
            }
            else
            {
                while (true)
                {
                    p = calcPosition(elementWidth, elementHeight, _visibleNumChildren);
                    if (clipH < p.y + elementHeight) break;
                    else _visibleNumChildren++;
                }
            }
        }
    }
}