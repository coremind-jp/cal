package jp.coremind.controller
{
    import flash.geom.Rectangle;

    public class SliderConfigure
    {
        public var
            slideArea:Rectangle,
            propertyHorizontal:String,
            minHorizontal:Number,
            maxHorizontal:Number,
            propertyVertical:String,
            minVertical:Number,
            maxVertical:Number;
            
        public function SliderConfigure(
            slideArea:Rectangle,
            propertyHorizontal:String = null, minHorizontal:Number = 0, maxHorizontal:Number = 0,
            propertyVertical  :String = null, minVertical  :Number = 0, maxVertical  :Number = 0)
        {
            this.slideArea = slideArea;
            
            this.propertyHorizontal = propertyHorizontal;
            this.minHorizontal      = minHorizontal;
            this.maxHorizontal      = maxHorizontal;
            
            this.propertyVertical   = propertyVertical;
            this.minVertical        = minVertical;
            this.maxVertical        = maxVertical;
        }
    }
}