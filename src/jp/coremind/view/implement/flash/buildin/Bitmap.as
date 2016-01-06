package jp.coremind.view.implement.flash.buildin
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Point;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class Bitmap extends flash.display.Bitmap implements IDisplayObject
    {
        public function Bitmap(bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
        {
            super(bitmapData, pixelSnapping, smoothing);
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
        
        public function toGlobalPoint(localPoint:Point, resultPoint:Point = null):Point
        {
            var p:Point = localToGlobal(localPoint);
            if (resultPoint)
            {
                resultPoint.setTo(p.x, p.y);
                return resultPoint;
            }
            else return p;
        }
        
        public function toLocalPoint(globalPoint:Point, resultPoint:Point = null):Point
        {
            var p:Point = globalToLocal(globalPoint);
            if (resultPoint)
            {
                resultPoint.setTo(p.x, p.y);
                return resultPoint;
            }
            else return p;
        }
    }
}