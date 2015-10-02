package jp.coremind.view.builder
{
    import jp.coremind.asset.Asset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.buildin.Image;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    import starling.textures.Texture;
    
    public class ImageBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private var
            _assetId:String,
            _atlasName:String;
        
        public function ImageBuilder(width:Size, height:Size, horizontalAlign:Align, verticalAlign:Align)
        {
            super(width, height, horizontalAlign, verticalAlign);
        }
        
        public function initialTexture(assetId:String, atlasName:String):ImageBuilder
        {
            _assetId = assetId;
            _atlasName = atlasName;
            return this;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var image:Image = _assetId && _atlasName ?
                new Image(Asset.texture(_assetId).getAtlasTexture(_atlasName)):
                new Image(Texture.empty(_width.calc(actualParentWidth), _height.calc(actualParentHeight)));
            
            image.name = name;
            image.x = _horizontalAlign.calc(actualParentWidth, image.width);
            image.y = _verticalAlign.calc(actualParentHeight, image.height);
            Log.info("builded Image", image.x, image.y, image.width, image.height)
            
            return image;
        }
    }
}