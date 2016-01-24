package jp.coremind.view.builder.parts
{
    import jp.coremind.asset.Asset;
    import jp.coremind.asset.Grid3ImageAsset;
    import jp.coremind.asset.TexturePicker;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.layout.Layout;
    import jp.coremind.view.builder.DisplayObjectBuilder;
    
    public class Grid3TextureBuilder extends DisplayObjectBuilder
    {
        private var
            _assetId:String,
            _headTextureName:String,
            _bodyTextureName:String,
            _tailTextureName:String;
        
        public function Grid3TextureBuilder(layout:Layout, headTextureName:String, bodyTextureName, tailTextureName:String, assetId:String)
        {
            super(layout);
            
            _assetId = assetId;
            _headTextureName = headTextureName;
            _bodyTextureName = bodyTextureName;
            _tailTextureName = tailTextureName;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var picker:TexturePicker = Asset.texture(_assetId);
            
            var child:Grid3ImageAsset = new Grid3ImageAsset().initializeForTexture(
                    picker.getAtlasTexture(_headTextureName),
                    picker.getAtlasTexture(_bodyTextureName),
                    picker.getAtlasTexture(_tailTextureName));
            
            child.name = name;
            
            Log.info("builded Grid3TextureBuilder");
            
            return child;
        }
    }
}