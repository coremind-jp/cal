package jp.coremind.view.interaction
{
    import jp.coremind.asset.Asset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    public class AtlasTextureInteraction extends ElementInteraction implements IElementInteraction
    {
        private var
            _assetId:String,
            _atlasId:String;
        
        public function AtlasTextureInteraction(applyTargetName:String, assetId:String, atlasId:*)
        {
            super(applyTargetName);
            
            _assetId = assetId;
            _atlasId = atlasId;
        }
        
        public function destroy():void
        {
        }
        
        public function apply(parent:IElement):void
        {
            var child:Image = parent.getDisplayByName(_name) as Image;
            
            if (child) child.texture = Asset.texture(_assetId).getAtlasTexture(_atlasId);
            else Log.warning("undefined Parts(AtlasTextureInteraction). name=", _name);
        }
    }
}