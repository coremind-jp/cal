package jp.coremind.view.builder.parts
{
    import jp.coremind.asset.Asset;
    
    import starling.display.Sprite;

    public class BitmapFont
    {
        private var
            _assetId:String,
            _fontface:String,
            _fontSize:int,
            _fontColor:uint,
            _hAlign:String,
            _vAlign:String,
            _autoScale:Boolean,
            _kerning:Boolean;
        
        public function BitmapFont(
            assetId:String,
            fontface:String=null,
            fontSize:int=-1,
            fontColor:uint=16777215,
            hAlign:String="center",
            vAlign:String="center",
            autoScale:Boolean=true,
            kerning:Boolean=true)
        {
            _assetId   = assetId;
            _fontface  = fontface;
            _fontSize  = fontSize;
            _fontColor = fontColor;
            _hAlign    = hAlign;
            _vAlign    = vAlign;
            _autoScale = autoScale;
            _kerning   = kerning;
        }
        
        public function create(text:String, width:Number, height:Number):Sprite
        {
            return Asset.texture(_assetId).getBitmapFont(_fontface).createSprite(
                width, height, text, _fontSize, _fontColor,
                _hAlign, _vAlign, _autoScale, _kerning);
        }
    }
}