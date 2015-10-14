package jp.coremind.view.interaction
{
    import jp.coremind.asset.Asset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    public class PainterTextureInteraction extends ElementInteraction implements IElementInteraction
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
        }
        
        public function destroy():void
        {
        }
        
        public function apply(parent:IElement):void
        {
            var child:Image = parent.getDisplayByName(_name) as Image;
            
            if (child) child.texture = Asset.texture(_assetId).getPaintTexture(_painterClass, _paintValue, _clipOption);
            else Log.warning("undefined Parts(PainterTextureInteraction). name=", _name);
        }
    }
}