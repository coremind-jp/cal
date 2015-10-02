package jp.coremind.view.abstract
{
    import jp.coremind.control.Controller;
    import jp.coremind.model.ElementModel;

    public interface IElement extends ICalSprite
    {
        /**
         * インスタンスを初期化する.
         * @params  storageId   インスタンスに対になるStorageModeReaderのstorageId
         */
        function initialize(actualParentWidth:int, actualParentHeight:int, storageId:String = null):void
            
        function updateElementSize(elementWidth:Number, elementHeight:Number):void;
        
        function get elementWidth():Number;
        function get elementHeight():Number;
        function get controller():Controller;
        function get storageId():String;
        function get elementId():String;
        function get elementModel():ElementModel;
        
        function addListener(type:String, listener:Function):void
        function removeListener(type:String, listener:Function):void
        function hasListener(type:String):void
    }
}