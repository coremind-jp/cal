package jp.coremind.view.parts
{
    import jp.coremind.resource.CircleTexture;
    import jp.coremind.resource.Color;
    import jp.coremind.resource.EmbedResource;
    import jp.coremind.utility.Log;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.abstract.component.Grid9;
    import jp.coremind.view.implement.starling.buildin.Image;
    import jp.coremind.view.implement.starling.buildin.Sprite;

    public class RectangleBackground implements IBackgroundBuilder
    {
        private static const NAME:String = "RectangleBackground";
        
        private var
            _color:uint,
            _radius:int,
            _topLeft:Boolean,
            _bottomLeft:Boolean,
            _bottomRight:Boolean,
            _topRight:Boolean;
        
        public function RectangleBackground(
            color:uint,
            radius:int = 0,
            topLeft:Boolean = true,
            bottomLeft:Boolean = true,
            bottomRight:Boolean = true,
            topRight:Boolean = true)
        {
            _color       = color;
            _radius      = radius;
            _topLeft     = topLeft;
            _bottomLeft  = bottomLeft;
            _bottomRight = bottomRight;
            _topRight    = topRight;
        }
        
        public function build(parent:IElement):IStretchBox
        {
            var beforeParts:IStretchBox = parent.getPartsByName(NAME);
            if (beforeParts)
            {
                beforeParts.destroy();
                parent.removeParts(beforeParts, true);
            }
            
            if (_radius == 0)
            {
                var rect:StretchImage = EmbedResource.createColorStretchImage(_color);
                rect.name = NAME;
                parent.addParts(rect);
                Log.info("background build ", parent);
                
                return rect;
            }
            else
            {
                var container:Sprite = new Sprite();
                container.name = NAME;
                parent.addParts(container);
                
                var tl:Image, tc:Image, tr:Image, ml:Image, mc:Image, mr:Image, bl:Image, bc:Image, br:Image;
                
                container.addChild(tl = _topLeft ?
                    EmbedResource.createCircleImage(CircleTexture.QUARTER_TOP_LEFT, _radius):
                    EmbedResource.createColorImage(_color, _radius, _radius));
                container.addChild(tc = EmbedResource.createColorImage(_color, _radius, _radius));
                container.addChild(tr = _topRight ?
                    EmbedResource.createCircleImage(CircleTexture.QUARTER_TOP_RIGHT, _radius):
                    EmbedResource.createColorImage(_color, _radius, _radius));
                
                container.addChild(ml = EmbedResource.createColorImage(_color, _radius, _radius));
                container.addChild(mc = EmbedResource.createColorImage(_color, _radius, _radius));
                container.addChild(mr = EmbedResource.createColorImage(_color, _radius, _radius));
                
                container.addChild(bl = _bottomLeft ?
                    EmbedResource.createCircleImage(CircleTexture.QUARTER_BOTTOM_LEFT, _radius):
                    EmbedResource.createColorImage(_color, _radius, _radius));
                container.addChild(bc = EmbedResource.createColorImage(_color, _radius, _radius));
                container.addChild(br = _bottomRight ?
                    EmbedResource.createCircleImage(CircleTexture.QUARTER_BOTTOM_RIGHT, _radius):
                    EmbedResource.createColorImage(_color, _radius, _radius));
                
                var roundRect:Grid9 = new Grid9();
                
                roundRect.setResource(container,
                    tl, tc, tr,
                    ml, mc, mr,
                    bl, bc, br);
                
                return roundRect;
            }
        }
    }
}