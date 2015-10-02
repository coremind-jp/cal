package jp.coremind.core
{
    import flash.display.Stage;
    
    import jp.coremind.view.abstract.LayerProcessor;

    public interface IViewAccessor
    {
        function initialize(stage:Stage, completeHandler:Function):void;
        
        function isInitialized():Boolean;
        
        function disablePointerDevice():void;
        
        function enablePointerDevice():void;
        
        function getLayerProcessor(layerIndex:String):LayerProcessor;
        
        function run():void;
    }
}