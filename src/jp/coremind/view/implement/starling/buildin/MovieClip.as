package jp.coremind.view.implement.starling.buildin
{
    import flash.geom.Point;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    import starling.display.MovieClip;
    import starling.textures.Texture;
    
    public class MovieClip extends starling.display.MovieClip implements IDisplayObject
    {
        public function MovieClip(textures:__AS3__.vec.Vector.<starling.textures.Texture>, fps:Number=12)
        {
            super(textures, fps);
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