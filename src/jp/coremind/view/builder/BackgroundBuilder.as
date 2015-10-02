package jp.coremind.view.builder
{
    import jp.coremind.asset.Asset;
    import jp.coremind.asset.painter.ColorPainter;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.implement.starling.BackgroundImage;
    
    public class BackgroundBuilder implements IBackgroundBuilder
    {
        private static const NAME:String = "BackgroundBuilder";
        
        private var
            _assetId:String,
            _color:uint;
        
        public function BackgroundBuilder(assetId:String, color:uint)
        {
            _assetId = assetId;
            _color   = color;
        }
        
        public function build(parent:IElement):IStretchBox
        {
            var image:BackgroundImage = new BackgroundImage(Asset.texture(_assetId).getPaintTexture(ColorPainter, _color));
            
            image.name = NAME;
            parent.addDisplay(image);
            Log.info("static backgroudn builded", _assetId, _color.toString(16));
            
            return image as IStretchBox;
        }
    }
}