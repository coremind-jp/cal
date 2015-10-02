package jp.coremind.core
{
    import jp.coremind.configure.ViewLayerConfigure;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.LayerProcessor;

    public class AbstractViewAccessor
    {
        private static const DEFAULT_LAYER_CONFIGURE:ViewLayerConfigure = new ViewLayerConfigure();
        
        private var
            _root:ICalSprite,
            _layerProcessorList:Object,
            _isInitialized:Boolean;
        
        public function AbstractViewAccessor()
        {
            _isInitialized = false;
            _layerProcessorList = {};
        }
        
        public function disablePointerDevice():void { _root.disablePointerDeviceControl(); }
        
        public function enablePointerDevice():void  { _root.enablePointerDeviceControl(); }
        
        public function isInitialized():Boolean { return _isInitialized; }
        
        public function initializeLayer(root:ICalSprite, layerClass:Class, commonViewClass:Class):void
        {
            _root = root;
            
            for (var i:int = 0; i < _configure.viewLength; i++) 
            {
                var layerName:String = _configure.getLayerName(i);
                var layer:ICalSprite = new layerClass(layerName);
                
                _layerProcessorList[layerName] = new LayerProcessor(layer, commonViewClass);
                _root.addDisplay(layer);
            }
            
            Log.info(_root.name, "initialized");
            _isInitialized = true;
        }
        
        private function get _configure():ViewLayerConfigure
        {
            return Application.configure.viewLayer || DEFAULT_LAYER_CONFIGURE;
        }
        
        public function getLayerProcessor(layerName:String):LayerProcessor
        {
            return _layerProcessorList[layerName];
        }
    }
}