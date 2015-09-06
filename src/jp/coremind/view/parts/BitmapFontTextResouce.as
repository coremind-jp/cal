package jp.coremind.view.parts
{
    import jp.coremind.resource.EmbedResource;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    
    import starling.display.Sprite;

    public class BitmapFontTextResouce extends TextResource
    {
        private var
            _fontface:String,
            _fontSize:int,
            _fontColor:uint,
            _hAlign:String,
            _vAlign:String,
            _autoScale:Boolean,
            _kerning:Boolean;
        
        public function BitmapFontTextResouce(applyTargetName:String, text:*, fontface:String=null, fontSize:int=-1, fontColor:uint=16777215, hAlign:String="center", vAlign:String="center", autoScale:Boolean=true, kerning:Boolean=true)
        {
            super(applyTargetName, text);
            
            _fontface  = fontface;
            _fontSize  = fontSize;
            _fontColor = fontColor;
            _hAlign    = hAlign;
            _vAlign    = vAlign;
            _autoScale = autoScale;
            _kerning   = kerning;
        }
        
        override public function apply(parent:IElement):void
        {
            var sprite:Sprite = parent.getPartsByName(_name);
            if (sprite)
            {
                var bitmapFont:Sprite = EmbedResource.getBitmapFont(_fontface).createSprite(
                    parent.elementWidth,
                    parent.elementHeight,
                    _text is Function ? _text(): _text,
                    _fontSize,
                    _fontColor,
                    _hAlign,
                    _vAlign,
                    _autoScale,
                    _kerning);
                
                bitmapFont.name = _name;
                
                parent.addPartsAt(bitmapFont, parent.getPartsIndex(sprite));
                sprite.removeFromParent(true);
            }
            else Log.warning("undefined Parts(SpriteForBitmapFont). name=", _name);
        }
    }
}