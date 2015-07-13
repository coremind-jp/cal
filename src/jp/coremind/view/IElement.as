package jp.coremind.view
{
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
        function get visibleTransition():Function;
        function get invisibleTransition():Function;
        
        function addListener(type:String, listener:Function):void
        function removeListener(type:String, listener:Function):void
        function hasListener(type:String):void
        
        //flash displayObject accessor
        function set name(v:String):void
        function get name():String
        
        function get x():Number;
        function set x(n:Number):void;
        
        function get y():Number;
        function set y(n:Number):void;
        
        function get scaleX():Number;
        function set scaleX(n:Number):void;
        
        function get scaleY():Number;
        function set scaleY(n:Number):void;
        
        function get width():Number;
        function set width(n:Number):void;
        
        function get height():Number;
        function set height(n:Number):void;
        
        function get alpha():Number;
        function set alpha(n:Number):void;
        
        function get visible():Boolean;
        function set visible(b:Boolean):void;
        
        function get storage():StorageAccessor;
        function get parentElement():IElementContainer;
        function refresh():void
    }
}