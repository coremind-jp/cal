package jp.coremind.view.layout
{
    import flash.geom.Point;
    
    import jp.coremind.control.Application;

    public class GlidLayout implements ILayout
    {
        public static const VARIABLE_DIRECTION_X:String = "variableDirectionX";
        public static const VARIABLE_DIRECTION_Y:String = "variableDirectionY";
        
        private var
            _variableDirection:String,
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
        
        public function calcMaxContains(global:Point, elementWidth:Number, elementHeight:Number):int
        {
            var w:Number = Application.stage.stageWidth;
            var h:Number = Application.stage.stageHeight;
            
            var drawbleX:int, drawbleY:int = 0;
            var overflowX:Boolean, overflowY:Boolean;
            for (var i:int; !overflowX && !overflowY; i++)
            {
                var p:Point = calcPosition(elementWidth, elementHeight, i);
                global.x + p.x + elementWidth  < w ? drawbleX = i: overflowX = true;
                global.y + p.y + elementHeight < h ? drawbleY = i: overflowY = true;
            }
            
            return drawbleX * drawbleY;
        }
    }
}