package jp.coremind.view.layout
{
    public class Align
    {
        public static const LEFT:Align   = new Align();
        public static const CENTER:Align = new Align().parentStandard(.5).childStandard(-.5);
        public static const RIGHT:Align  = new Align().parentStandard(1).childStandard(-1);
        
        public static const TOP:Align    = new Align();
        public static const MIDDLE:Align = new Align().parentStandard(.5).childStandard(-.5);
        public static const BOTTOM:Align = new Align().parentStandard(1).childStandard(-1);
        
        private var
            _parentStandardAlign:Number,
            _childStandardAlign:Number,
            _pixelOffset:int;
            
        public function Align()
        {
            _parentStandardAlign = _childStandardAlign = _pixelOffset = 0;
        }
        
        public function clone():Align
        {
            var result:Align = new Align();
            
            result._parentStandardAlign = _parentStandardAlign;
            result._childStandardAlign = _childStandardAlign;
            result._pixelOffset = _pixelOffset;
            
            return result;
        }
        
        public function parentStandard(align:Number):Align
        {
            _parentStandardAlign = align;
            return this;
        }
        
        public function childStandard(align:Number):Align
        {
            _childStandardAlign = align;
            return this;
        }
        
        public function pixelOffset(pixel:int):Align
        {
            _pixelOffset = pixel;
            return this;
        }
        
        public function calc(parentBoxSize:Number, childBoxSize:Number):int
        {
            return (parentBoxSize * _parentStandardAlign + childBoxSize * _childStandardAlign + _pixelOffset);
        }
    }
}