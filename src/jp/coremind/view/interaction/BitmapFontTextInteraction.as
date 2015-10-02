package jp.coremind.view.interaction
{
    import jp.coremind.asset.Asset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    
    import starling.display.Sprite;

    public class BitmapFontTextInteraction extends TextInteraction
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
        
        public function BitmapFontTextInteraction(applyTargetName:String, text:*, assetId:String, fontface:String=null, fontSize:int=-1, fontColor:uint=16777215, hAlign:String="center", vAlign:String="center", autoScale:Boolean=true, kerning:Boolean=true)
        {
            super(applyTargetName, text);
            
            _assetId   = assetId;
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
            //BitmapFont::createSpriteはStarlingの純粋なSpriteクラスでしか取得できないため、
            //IDisplayObjectContainer::getDisplayByName経由で取得するとnullになる(内部でIDisplayObject型へのキャストをしている為)
            //なのでこの処理だけは特別で純粋なSpriteクラスを利用しなければならない
            var starlingParent:Sprite = parent as Sprite;
            var before:Sprite = starlingParent.getChildByName(_name) as Sprite;
            if (before)
            {
                var bitmapFont:Sprite = Asset.texture(_assetId).getBitmapFont(_fontface).createSprite(
                    parent.elementWidth,
                    parent.elementHeight,
                    _getText(parent),
                    _fontSize,
                    _fontColor,
                    _hAlign,
                    _vAlign,
                    _autoScale,
                    _kerning);
                
                bitmapFont.name = _name;
                
                starlingParent.addChildAt(bitmapFont, starlingParent.getChildIndex(before));
                before.removeFromParent(true);
            }
            else Log.warning("undefined Parts(SpriteForBitmapFont). name=", _name);
        }
    }
}