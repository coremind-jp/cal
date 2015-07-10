package jp.coremind.view
{
    import flash.geom.Point;
    
    import jp.coremind.model.StorageAccessor;

    public interface IElement
    {
        function initialize(model:StorageAccessor):void
        function destroy():void;
        
        function enablePointerDeviceControl():void;
        function disablePointerDeviceControl():void;
        
        function get elementWidth():Number;
        function get elementHeight():Number;
        
        function get addTransition():Function;
        function get mvoeTransition():Function;
        function get removeTransition():Function;
        
        //flash displayObject accessor
        function set name(v:String):void
        function get name():String
        
        function get x():Number;
        function set x(n:Number):void;
        
        function get y():Number;
        function set y(n:Number):void;
        
        function get width():Number;
        function set width(n:Number):void;
        
        function get height():Number;
        function set height(n:Number):void;
        
        function get storage():StorageAccessor;
        function get parentElement():IElementContainer;
    }
}