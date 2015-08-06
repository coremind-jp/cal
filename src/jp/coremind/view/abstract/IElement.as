package jp.coremind.view.abstract
{
    import jp.coremind.control.Controller;
    import jp.coremind.model.StorageModelReader;

    public interface IElement extends IDisplayObject
    {
        function initialize(reader:StorageModelReader):void;
        function destroy():void;
        
        /**
         * マウスやタップイベントのリスニングを有効にする.
         */
        function enablePointerDeviceControl():void;
        
        /**
         * マウスやタップイベントのリスニングを無効にする.
         */
        function disablePointerDeviceControl():void;
        
        function get elementWidth():Number;
        function get elementHeight():Number;
        function get controller():Controller;
        
        function get addTransition():Function;
        function get mvoeTransition():Function;
        function get removeTransition():Function;
        function get visibleTransition():Function;
        function get invisibleTransition():Function;
        
        function addListener(type:String, listener:Function):void
        function removeListener(type:String, listener:Function):void
        function hasListener(type:String):void
        
        function get parentElement():IElementContainer;
        function refresh():void
    }
}