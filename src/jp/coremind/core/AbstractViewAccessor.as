package jp.coremind.core
{
    import jp.coremind.configure.IViewTransition;
    import jp.coremind.configure.ViewConfigure;
    import jp.coremind.configure.ViewLayerConfigure;
    import jp.coremind.control.Controller;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.LayerProcessor;

    public class AbstractViewAccessor
    {
        private static const DEFAULT_LAYER_CONFIGURE:ViewLayerConfigure = new ViewLayerConfigure();
        
        private var
            _root:ICalSprite,
            _layerProcessorList:Object;
        
        public function AbstractViewAccessor()
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
        
        public function updateView(transition:IViewTransition):void
        {
            for (var i:int = 0; i < _configure.viewLength; i++) 
            {
                var layerName:String = _configure.getLayerName(i);
                var configure:ViewConfigure = transition.getViewConfigure(layerName);
                if (configure)
                {
                    var pId:String = String(transition)+" "+layerName;
                    Log.info(_root.name, "updateView", layerName);
                    getLayerProcessor(layerName).updateView(pId, configure, _commonView);
                    Controller.getInstance().syncProcess.run(pId);
                }
            }
        }
        
        protected function get _commonView():Class
        {
            return null;
        }
    }
}