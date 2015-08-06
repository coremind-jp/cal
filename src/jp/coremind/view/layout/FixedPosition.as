package jp.coremind.view.layout
{
    public class FixedPosition extends Position implements IPosition
    {
        public function FixedPosition(p:Number, align:Number)
        {
            super(p, align);
        }
        
        public function calc(parentBoxSize:Number):Number
        {
            return parentBoxSize * _align + _p;
        }
    }
}