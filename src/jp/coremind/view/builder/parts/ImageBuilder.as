package jp.coremind.view.builder.parts
{
    import jp.coremind.asset.Asset;
    import jp.coremind.asset.painter.ColorPainter;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.buildin.Image;
    import jp.coremind.view.layout.Layout;
    
    import starling.textures.Texture;
    import jp.coremind.view.builder.DisplayObjectBuilder;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
    
    public class ImageBuilder extends DisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private var
            _assetId:String,
            _color:uint,
            _atlasName:String;
        
        public function ImageBuilder(layout:Layout = null)
        {
            super(layout);
        }
        
        public function initialTexture(assetId:String, atlasName:String):ImageBuilder
        {
            _assetId = assetId;
            _atlasName = atlasName;
            return this;
        }
        
        public function initialColor(assetId:String, color:uint):ImageBuilder
        {
            _assetId = assetId;
            _color = color;
            return this;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var image:Image;
            if (_assetId)
            {
                if (_atlasName)
                {
                    image = new Image(Asset.texture(_assetId).getAtlasTexture(_atlasName));
                    
                    //アトラステクスチャの場合、サイズを定義に反映させる.(定数を使っている可能性があるので複製する)
                    _layout = _layout.clone();
                    _layout.width.setAtlasTextureSize(image.width);
                    _layout.height.setAtlasTextureSize(image.height);
                }
                else
                {
                    image = new Image(Asset.texture(_assetId).getPaintTexture(ColorPainter, _color));
                    image.width  = _layout.width.calc(actualParentWidth);
                    image.height = _layout.height.calc(actualParentHeight);
                }
            }
            else　image = new Image(Texture.empty(
                _layout.width.calc(actualParentWidth),
                _layout.height.calc(actualParentHeight)));
            
            image.name = name;
            image.x = _layout.horizontalAlign.calc(actualParentWidth, image.width);
            image.y = _layout.verticalAlign.calc(actualParentHeight, image.height);
            
            Log.info("builded Image", image.x, image.y, image.width, image.height)
            
            return image;
        }
    }
}