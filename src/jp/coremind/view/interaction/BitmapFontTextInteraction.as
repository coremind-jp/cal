package jp.coremind.view.interaction
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.BitmapFont;
    
    import starling.display.Sprite;

    public class BitmapFontTextInteraction extends TextInteraction
    {
        private var _bitmapFont:BitmapFont;
        
        public function BitmapFontTextInteraction(applyTargetName:String, assetId:String, fontface:String=null, fontSize:int=-1, fontColor:uint=16777215, hAlign:String="center", vAlign:String="center", autoScale:Boolean=true, kerning:Boolean=true)
        {
            super(applyTargetName);
            _bitmapFont = new BitmapFont(assetId, fontface, fontSize, fontColor, hAlign, vAlign, autoScale, kerning);
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
                var text:String = doInteraction(parent);
                var newSprite:Sprite = _bitmapFont.create(
                    text,
                    parent.elementWidth,
                    parent.elementHeight);
                newSprite.name = _name;
                
                starlingParent.addChildAt(newSprite, starlingParent.getChildIndex(before));
                before.removeFromParent(true);
            }
            else Log.warning("undefined Parts(SpriteForBitmapFont). name=", _name);
        }
    }
}