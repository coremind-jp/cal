package jp.coremind.view.abstract
{
    import jp.coremind.control.Controller;

    public interface IElement extends IDisplayObject
    {
        /**
         * インスタンスを初期化する.
         * @params  storageId   インスタンスに対になるStorageModeReaderのstorageId
         */
        function initialize(storageId:String = null):void;
        
        /** 破棄する. */
        function destroy(withReference:Boolean = false):void;
        
        /**
         * マウスやタップイベントのリスニングを有効にする.
         */
        function enablePointerDeviceControl():void;
        
        /**
         * マウスやタップイベントのリスニングを無効にする.
         */
        function disablePointerDeviceControl():void;
        
        function initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        function updateElementSize(elementWidth:Number, elementHeight:Number):void;
        function get elementWidth():Number;
        function get elementHeight():Number;
        
        function get controller():Controller;
        function get storageId():String;
        
        function get addTransition():Function;
        function get mvoeTransition():Function;
        function get removeTransition():Function;
        function get visibleTransition():Function;
        function get invisibleTransition():Function;
        
        function addListener(type:String, listener:Function):void
        function removeListener(type:String, listener:Function):void
        function hasListener(type:String):void
        
        function getPartsByName(name:String):*;
        function getPartsIndex(parts:*):int;
        function addParts(parts:*):*
        function addPartsAt(parts:*, index:int):*
        function removeParts(parts:*, dispose:Boolean = false):*;
        
        function get parentElement():IElementContainer;
    }
}