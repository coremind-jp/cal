package jp.coremind.view.implement.starling.buildin
{
    import flash.geom.Point;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    import starling.text.TextField;
    
    public class TextField extends starling.text.TextField implements IDisplayObject
    {
        public function TextField(width:int, height:int, text:String, fontName:String="Verdana", fontSize:Number=12, color:uint=0, bold:Boolean=false)
        {
            super(width, height, text, fontName, fontSize, color, bold);
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