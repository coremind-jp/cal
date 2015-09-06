package jp.coremind.view.builder
{
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.LayoutCalculator;
    import jp.coremind.view.layout.Size;

    public class BuildinDisplayObjectBuilder
    {
        protected var
            _width:Size,
            _height:Size,
            _horizontalAlign:Align,
            _verticalAlign:Align;
            
        public function BuildinDisplayObjectBuilder(
            width:Size,
            height:Size,
            horizontalAlign:Align,
            verticalAlign:Align)
        {
            _width = width;
            _height = height;
            _horizontalAlign = horizontalAlign;
            _verticalAlign = verticalAlign;
        }
        
        public function requestLayoutCalculator():LayoutCalculator
        {
            return new LayoutCalculator(_width, _height, _horizontalAlign, _verticalAlign);
        }
    }
}