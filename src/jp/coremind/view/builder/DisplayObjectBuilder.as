package jp.coremind.view.builder
{
    import jp.coremind.view.layout.Layout;

    public class DisplayObjectBuilder
    {
        protected var
            _layout:Layout;
            
        public function DisplayObjectBuilder(layout:Layout)
        {
            _layout = layout || Layout.EQUAL_PARENT_TL;
        }
        
        public function get layout():Layout
        {
            return _layout;
        }
    }
}