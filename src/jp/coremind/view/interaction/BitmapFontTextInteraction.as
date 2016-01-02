package jp.coremind.view.interaction
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.BitmapFont;
    
    import starling.display.Sprite;

    public class BitmapFontTextInteraction extends TextInteraction
    {
        private var _bitmapFont:BitmapFont;
        
        public function BitmapFontTextInteraction(applyTargetName:String, text:String, assetId:String, replacer:Function = null, fontface:String=null, fontSize:int=-1, fontColor:uint=16777215, hAlign:String="center", vAlign:String="center", autoScale:Boolean=true, kerning:Boolean=true)
        {
            super(applyTargetName, text, replacer);
            
            _bitmapFont = new BitmapFont(
                assetId, fontface, fontSize, fontColor,
                hAlign, vAlign, autoScale, kerning);
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
                var createdSprite:Sprite = _bitmapFont.create(
                    _getText(parent.elementInfo.reader),
                    parent.elementWidth,
                    parent.elementHeight);
                createdSprite.name = _name;
                
                starlingParent.addChildAt(createdSprite, starlingParent.getChildIndex(before));
                before.removeFromParent(true);
            }
            else Log.warning("undefined Parts(SpriteForBitmapFont). name=", _name);
        }
    }
}