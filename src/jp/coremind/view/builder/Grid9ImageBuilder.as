package jp.coremind.view.builder
{
    import jp.coremind.asset.Grid9ImageAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.component.Grid9;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    import starling.textures.Texture;
    
    public class Grid9ImageBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private var
            _tl:Texture, _t :Texture, _tr:Texture,
            _l :Texture, _c :Texture, _r :Texture,
            _bl:Texture, _b :Texture, _br:Texture;
        
        public function Grid9ImageBuilder(
            width:Size, height:Size, horizontalAlign:Align, verticalAlign:Align,
            topLeft:Texture,    top:Texture,    topRight:Texture,
            left:Texture,       body:Texture,   right:Texture,
            bottomLeft:Texture, bottom:Texture, bottomRight:Texture)
        {
            super(width, height, horizontalAlign, verticalAlign);
            
            _tl = topLeft;
            _t  = top;
            _tr = topRight;
            _l  = left;
            _c  = body;
            _r  = right;
            _bl = bottomLeft;
            _b  = bottom;
            _br = bottomRight;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var asset:Grid9ImageAsset = new Grid9ImageAsset().initializeForTexture(
                _tl, _t, _tr,
                 _l, _c, _r,
                _bl, _b, _br);
            
            asset.name = name;
            
            var grid9:Grid9 = new Grid9().setAsset(asset);
            grid9.width  = _width.calc(actualParentWidth);
            grid9.height = _height.calc(actualParentHeight);
            
            Log.info("builded Grid9Image", asset.width, asset.height);
            
            return grid9;
        }
    }
}