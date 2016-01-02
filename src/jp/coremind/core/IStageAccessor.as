package jp.coremind.core
{
    import flash.display.Stage;
    
    import jp.coremind.view.abstract.LayerProcessor;
    import jp.coremind.configure.ITransitionContainer;

    public interface IStageAccessor
    {
        function initialize(stage:Stage, completeHandler:Function):void;
        
        function isInitialized():Boolean;
        
        function disablePointerDevice():void;
        
        function enablePointerDevice():void;
        
        function getLayerProcessor(layerName:String):LayerProcessor;
        
        function update(transitionContainer:ITransitionContainer, callback:Function = null):void;
    }
}