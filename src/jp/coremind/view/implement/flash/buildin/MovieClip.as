package jp.coremind.view.implement.flash.buildin
{
    import flash.display.MovieClip;
    import flash.geom.Point;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class MovieClip extends flash.display.MovieClip implements IDisplayObject
    {
        public function MovieClip()
        {
            super();
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
        
        public function enablePointerDeviceControl():void
        {
            mouseChildren = mouseEnabled = true;
        }
        
        public function disablePointerDeviceControl():void
        {
            mouseChildren = mouseEnabled = false;
        }
    }
}