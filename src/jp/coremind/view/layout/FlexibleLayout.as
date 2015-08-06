package jp.coremind.view.layout
{
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.Log;

    public class FlexibleLayout extends AbstractLayout implements ILayout
    {
        private var
            _elementClassList:Vector.<Class>,
            _xList:Vector.<IPosition>,
            _yList:Vector.<IPosition>;
        
        public function FlexibleLayout(temporaryRect:Rectangle = null)
        {
            super(temporaryRect);
            
            _elementClassList = new <Class>[];
            _xList = new <IPosition>[];
            _yList = new <IPosition>[];
        }
        
        override public function destroy():void
        {
            _elementClassList.length = 0;
            _xList.length = _yList.length = 0;
            
            super.destroy();
        }
        
        public function appendElement(elementClass:Class, x:IPosition, y:IPosition):FlexibleLayout
        {
            _elementClassList.push(elementClass);
            _xList.push(x);
            _yList.push(y);
            
            return this;
        }
        
        public function getElementClass(index:int):Class
        {
            if (0 <= index && index < _elementClassList.length)
                return _elementClassList[index];
            else
            {
                Log.error("[FlexibleElementClassLayout]", index, " is undefined.");
                return null;
            }
        }
        
        public function calcElementRect(
            parentWidth:Number,
            parentHeight:Number,
            index:int,
            length:int = 0):Rectangle
        {
            var e:Class = getElementClass(index);
            if (e)
            {
                var childW:Number = ElementSize.getWidth(e, 0);
                var childH:Number = ElementSize.getHeight(e, 0);
                var r:Rectangle   = _rect || new Rectangle();
                
                r.setTo(_xList[index].calc(parentWidth), _yList[index].calc(parentHeight), childW, childH);
                
                return r;
            }
            else
                return _rect || new Rectangle();
        }
        
        public function calcTotalRect(
            parentWidth:Number,
            parentHeight:Number,
            index:int,
            length:int = 0):Rectangle
        {
            var temp:Rectangle = _rect;
            var _lowX:Number  = 0;
            var _lowY:Number  = 0;
            var _highX:Number = 0;
            var _highY:Number = 0;
            
            _rect = new Rectangle();
            for (var i:int, len:int = _elementClassList.length; i < len; i++)
            {
                calcElementRect(parentWidth, parentHeight, index, length);
                if (_rect.x < _lowX)      _lowX  = _rect.x;
                if (_rect.y < _lowY)      _lowY  = _rect.y;
                if (_highX  < _rect.left) _highX = _rect.left;
                if (_highY  < _rect.y)    _highY = _rect.bottom;
            }
            _rect = temp;
            
            var r:Rectangle = _rect || new Rectangle();
            r.setTo(0, 0, _highX - _lowX, _highY - _lowY);
            
            return r;
        }
    }
}