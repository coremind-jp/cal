package jp.coremind.view.interaction
{
    import jp.coremind.asset.Grid9ImageAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    
    import starling.textures.Texture;

    public class Grid9TextureInteraction extends ElementInteraction
    {
        private var
            _tl:Texture, _t :Texture, _tr:Texture,
            _l :Texture, _c :Texture, _r :Texture,
            _bl:Texture, _b :Texture, _br:Texture;
        
        public function Grid9TextureInteraction(
            applyTargetName:String,
            topLeft:Texture,    top:Texture,    topRight:Texture,
            left:Texture,       body:Texture,   right:Texture,
            bottomLeft:Texture, bottom:Texture, bottomRight:Texture)
        {
            super(applyTargetName);
            
            _tl = topLeft;
            _t  = top;
            _tr = topRight;
            _l  = left;
            _c  = body;
            _r  = right;
            _bl = bottomLeft;
            _b  = bottom;
            _br = bottomRight;
            
            _injectionCode = function(previewValue:*, child:Grid9ImageAsset):void
            {
                child.update(_tl, _t, _tr, _l, _c, _r, _bl, _b, _br);
            };
        }
        
        override public function destroy():void
        {
            _tl =  _t  = _tr =
            _l  =  _c  =  _r =
            _bl =  _b  = _br = null;
            
            super.destroy();
        }
        
        override public function apply(parent:IElement, previewData:*):void
        {
            var asset:Grid9ImageAsset = parent.getDisplayByName(_name) as Grid9ImageAsset;
            if (asset) doInteraction(parent, previewData, asset);
            else Log.warning("undefined Parts(Grid9ImageTexture). name=", _name);
        }
    }
}