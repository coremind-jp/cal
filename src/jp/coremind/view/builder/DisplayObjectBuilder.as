package jp.coremind.view.builder
{
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.layout.Layout;

    public class DisplayObjectBuilder implements IDisplayObjectBuilder
    {
        protected var
            _enabledPointerDevice:Boolean,
            _layout:Layout;
            
        public function DisplayObjectBuilder(layout:Layout)
        {
            _layout = layout || Layout.EQUAL_PARENT_TL;
            _enabledPointerDevice = false;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            return null;
        }
        
        public function touchable(boolean:Boolean = true):IDisplayObjectBuilder
        {
            _enabledPointerDevice = boolean;
            return this;
        }
        
        public function get enabledPointerDevice():Boolean
        {
            return _enabledPointerDevice;
        }
        
        public function get layout():Layout
        {
            return _layout;
        }
    }
}