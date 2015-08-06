package jp.coremind.view.layout
{
    import jp.coremind.utility.Log;

    public class RelativePosition extends Position implements IPosition
    {
        public function RelativePosition(p:Number, align:Number)
        {
            super(p, align);
        }
        
        public function calc(parentBoxSize:Number):Number
        {
            return parentBoxSize * _align + parentBoxSize * _p;
        }
    }
}