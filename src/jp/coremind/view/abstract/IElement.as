package jp.coremind.view.abstract
{
    import jp.coremind.model.StorageAccessor;

    public interface IElement extends IDisplayObject
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
        
        function get storage():StorageAccessor;
        function get parentElement():IElementContainer;
        function refresh():void
    }
}