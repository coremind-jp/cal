package jp.coremind.view.implement.starling.buildin
{
    import flash.geom.Point;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class Image extends starling.display.Image implements IDisplayObject
    {
        public function Image(texture:Texture)
        {
            super(texture);
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
        
        public function enablePointerDeviceControl():void
        {
            touchable = true;
        }
        
        public function disablePointerDeviceControl():void
        {
            touchable = false;
        }
    }
}