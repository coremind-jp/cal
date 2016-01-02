package jp.coremind.view.abstract
{
    import jp.coremind.event.ElementInfo;

    public interface IElement extends ICalSprite
    {
        /**
         * インスタンスを初期化する.
         * @params  storageId   インスタンスに対になるStorageModeReaderのstorageId
         */
        function initialize(actualParentWidth:int, actualParentHeight:int, storageId:String = null, storageInteractionId:String = null, runInteractionOnCreated:Boolean = false):void
            
        function updateElementSize(elementWidth:Number, elementHeight:Number):void;
        
        function get elementInfo():ElementInfo;
        function get elementWidth():Number;
        function get elementHeight():Number;
        
        function addListener(type:String, listener:Function):void
        function removeListener(type:String, listener:Function):void
        function hasListener(type:String):void
    }
}