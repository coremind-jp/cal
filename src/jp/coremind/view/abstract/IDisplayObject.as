package jp.coremind.view.abstract
{
    import flash.geom.Point;

    //flash DisplayObject accessor
    public interface IDisplayObject extends IBox
    {
        function get parentDisplay():IDisplayObjectContainer;
        
        function set name(v:String):void
        function get name():String
        
        function get alpha():Number;
        function set alpha(n:Number):void;
        
        function set visible(b:Boolean):void;
        function get visible():Boolean;
        
        function toLocalPoint(globalPoint:Point, resultPoint:Point = null):Point;
        function toGlobalPoint(localPoint:Point, resultPoint:Point = null):Point;
    }
}