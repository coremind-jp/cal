package jp.coremind.view.builder
{
    import jp.coremind.asset.Color;
    import jp.coremind.asset.EmbedAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.buildin.Image;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    public class ImageBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        public function ImageBuilder(width:Size, height:Size, horizontalAlign:Align, verticalAlign:Align)
        {
            super(width, height, horizontalAlign, verticalAlign);
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var image:Image = EmbedAsset.createColorImage(
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