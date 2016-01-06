package jp.coremind.view.implement.starling.buildin
{
    import flash.geom.Point;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    import starling.display.Quad;
    
    public class Quad extends starling.display.Quad implements IDisplayObject
    {
        public function Quad(width:Number, height:Number, color:uint=16777215, premultipliedAlpha:Boolean=true)
        {
            super(width, height, color, premultipliedAlpha);
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
        
        public function toGlobalPoint(localPoint:Point, resultPoint:Point = null):Point
        {
            return localToGlobal(localPoint, resultPoint);
        }
        
        public function toLocalPoint(globalPoint:Point, resultPoint:Point = null):Point
        {
            return globalToLocal(globalPoint, resultPoint);
        }
    }
}