package jp.coremind.view.builder
{
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.component.Grid3;
    import jp.coremind.view.abstract.component.Grid3X;
    import jp.coremind.view.abstract.component.Slider;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    import jp.coremind.view.implement.starling.component.ScrollContainer;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    import starling.display.DisplayObject;
    
    public class ScrollOption
    {
        private var
            _grid3:Grid3,
            _horizontal:Align,
            _vertical:Align,
            _scrollLength:Size,
            _headImage:IDisplayObject,
            _bodyImage:IDisplayObject,
            _tailImage:IDisplayObject;
        
        public function ScrollOption(
            grid3:Grid3,
            horizontal:Align,
            vertical:Align,
            scrollLength:Size,
            headImage:IDisplayObject,
            bodyImage:IDisplayObject,
            tailImage:IDisplayObject)
        {
            _grid3 = grid3;
            _horizontal = horizontal;
            _vertical = vertical;
            _scrollLength = scrollLength;
            _bodyImage = bodyImage;
            _headImage = headImage;
            _tailImage = tailImage;
        }
        
        public function build(scrollContainer:ScrollContainer):void
        {
            var w:Number = scrollContainer.maxWidth;
            var h:Number = scrollContainer.maxHeight;
            
            var sliderContainer:Sprite = new Sprite();
            sliderContainer.addChild(_bodyImage as DisplayObject);
            sliderContainer.addChild(_headImage as DisplayObject);
            sliderContainer.addChild(_tailImage as DisplayObject);
            
            _grid3.setResource(sliderContainer, _headImage, _bodyImage, _tailImage);
            
            scrollContainer.addChild(sliderContainer);
            
            if (_grid3 is Grid3X)
            {
                scrollContainer.sliderX = new Slider(_grid3, _scrollLength.calc(w), _horizontal.calc(w, 5));
                sliderContainer.y = _vertical.calc(h, sliderContainer.height);
            }
            else
            {
                scrollContainer.sliderY = new Slider(_grid3, _scrollLength.calc(h), _vertical.calc(h, 5));
                sliderContainer.x = _horizontal.calc(w, 0);
            }
        }
    }
}