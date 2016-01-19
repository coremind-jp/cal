package jp.coremind.view.interaction
{
    import jp.coremind.asset.Asset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    public class PainterTextureInteraction extends ElementInteraction
    {
        private var
            _assetId:String,
            _painterClass:Class,
            _paintValue:*,
            _clipOption:int;
        
        public function PainterTextureInteraction(applyTargetName:String, assetId:String, painterClass:Class, paintValue:*, clipOption:int = 0)
        {
            super(applyTargetName);
            
            _assetId = assetId;
            _painterClass = painterClass;
            _paintValue = paintValue;
            _clipOption = clipOption;
            
            _injectionCode = function(previewValue:*, child:Image):void
            {
                child.texture = Asset.texture(_assetId).getPaintTexture(_painterClass, _paintValue, _clipOption);
            };
        }
        
        override public function apply(parent:IElement, previewData:*):void
        {
            var child:Image = parent.getDisplayByName(_name) as Image;
            
            if (child) doInteraction(parent, previewData, child);
            else Log.warning("undefined Parts(PainterTextureInteraction). name=", _name);
        }
    }
}