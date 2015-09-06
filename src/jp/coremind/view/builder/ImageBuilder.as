package jp.coremind.view.builder
{
    import jp.coremind.resource.Color;
    import jp.coremind.resource.EmbedResource;
    import jp.coremind.utility.Log;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    import starling.display.DisplayObject;
    import starling.display.Image;
    
    public class ImageBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        public function ImageBuilder(width:Size, height:Size, horizontalAlign:Align, verticalAlign:Align)
        {
            super(width, height, horizontalAlign, verticalAlign);
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):DisplayObject
        {
            var image:Image = EmbedResource.createColorImage(
                Color.TRANSPARENT,
                 _width.calc(actualParentWidth),
                _height.calc(actualParentHeight));
            
            image.name = name;
            //image.touchable = false;
            Log.info("builded Image", image.width, image.height)
            
            return image;
        }
    }
}