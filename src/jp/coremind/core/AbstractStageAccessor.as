package jp.coremind.core
{
    import jp.coremind.configure.ITransitionContainer;
    import jp.coremind.configure.ViewLayerConfigure;
    import jp.coremind.event.TransitionEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Process;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.LayerProcessor;

    public class AbstractStageAccessor
    {
        private static const DEFAULT_LAYER_CONFIGURE:ViewLayerConfigure = new ViewLayerConfigure();
        
        private var
            _root:ICalSprite,
            _layerProcessorList:Object;
        
        public function AbstractStageAccessor()
        {
            _layerProcessorList = {};
        }
        
        protected function get root():ICalSprite { return _root; }
        
        public function disablePointerDevice():void { _root.disablePointerDeviceControl(); }
        
        public function enablePointerDevice():void  { _root.enablePointerDeviceControl(); }
        
        public function isInitialized():Boolean { return Boolean(_root); }
        
        public function initializeLayer(root:ICalSprite, layerClass:Class):void
        {
            _root = root;
            
            for (var i:int = 0; i < _configure.viewLength; i++) 
            {
                var layerName:String = _configure.getLayerName(i);
                var layer:ICalSprite = new layerClass(layerName);
                
                _layerProcessorList[layerName] = new LayerProcessor(layer);
                _root.addDisplay(layer);
            }
            
            Log.info(_root.name, "initialized");
        }
        
        private function get _configure():ViewLayerConfigure
        {
            return Application.configure.viewLayer || DEFAULT_LAYER_CONFIGURE;
        }
        
        public function getLayerProcessor(layerName:String):LayerProcessor
        {
            return _layerProcessorList[layerName];
        }
        
        private var id:int = 0;
        public function update(transitionContainer:ITransitionContainer, callback:Function = null):void
        {
            var completeNum:int = 0;
            var completeHandler:Function = function(process:Process):void
            {
                if (++completeNum < transitionContainer.length) return;
                
                Application.globalEvent.dispatchEvent(
                    new TransitionEvent(
                        TransitionEvent.END_TRANSITION,
                        null,
                        transitionContainer));
                
                if (callback is Function) callback(process);
            };
            
            Application.globalEvent.dispatchEvent(
                new TransitionEvent(
                    TransitionEvent.BEGIN_TRANSITION,
                    null,
                    transitionContainer));
            
            for (var i:int = 0; i < _configure.viewLength; i++) 
            {
                var layerName:String = _configure.getLayerName(i);
                var layerProcessor:LayerProcessor = getLayerProcessor(layerName);
                var transition:Transition = transitionContainer.getTransition(layerName);
                
                if (transitionContainer.deleteRestoreHistory)
                    layerProcessor.deleteRestoreHistory();
                
                if (transition)
                {
                    var pId:String = String(id++)+" "+layerName;
                    layerProcessor.update(pId, _commonView, transition);
                    Application.sync.exec(pId, completeHandler);
                }
                else layerProcessor.pushEmptyTransition();
            }
        }
        
        protected function get _commonView():Class
        {
            return null;
        }
    }
}