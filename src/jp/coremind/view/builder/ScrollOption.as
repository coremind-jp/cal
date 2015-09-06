package jp.coremind.view.builder
{
    import jp.coremind.view.abstract.component.Grid3;
    import jp.coremind.view.abstract.component.Grid3X;
    import jp.coremind.view.abstract.component.Slider;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    import jp.coremind.view.implement.starling.component.ScrollContainer;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    public class ScrollOption
    {
        private var
            _grid3:Grid3,
            _horizontal:Align,
            _vertical:Align,
            _scrollLength:Size;
        
        public function ScrollOption(
            grid3:Grid3,
            horizontal:Align,
            vertical:Align,
            scrollLength:Size)
        {
            _grid3 = grid3;
            _horizontal = horizontal;
            _vertical = vertical;
            _scrollLength = scrollLength;
        }
        
        public function build(scrollContainer:ScrollContainer):void
        {
            var w:Number = scrollContainer.maxWidth;
            var h:Number = scrollContainer.maxHeight;
            
            if (_grid3 is Grid3X)
            {
                scrollContainer.sliderX = new Slider(_grid3, _scrollLength.calc(w), _horizontal.calc(w, 5));
                _grid3.asset.y = _vertical.calc(h, _grid3.asset.height);
            }
            else
            {
                scrollContainer.sliderY = new Slider(_grid3, _scrollLength.calc(h), _vertical.calc(h, 5));
                _grid3.asset.x = _horizontal.calc(w, 0);
            }
            
            scrollContainer.addChild(_grid3.asset as Sprite);
        }
    }
}