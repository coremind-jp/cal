package jp.coremind.configure
{
    public class ViewTransition implements IViewTransition
    {
        private var
            _layerType:String,
            _configure:Object;
        
        public function ViewTransition(layerType:String = LayerType.STARLING)
        {
            _layerType = layerType;
            _configure = {};
        }
        
        public function get layerType():String
        {
            return _layerType;
        }
        
        public function setViewConfigure(layer:String, configure:ViewConfigure):ViewTransition
        {
            _configure[layer] = configure;
            return this;
        }
        
        public function getViewConfigure(layer:String):ViewConfigure
        {
            return layer in _configure ? _configure[layer]: null;
        }
    }
}