package jp.coremind.view.implement.flash.buildin
{
    import flash.display.Shape;
    import flash.geom.Point;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class Shape extends flash.display.Shape implements IDisplayObject
    {
        public function Shape()
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
    }
}