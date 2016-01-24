package jp.coremind.view.builder.parts
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    import jp.coremind.view.layout.Layout;
    import jp.coremind.view.builder.DisplayObjectBuilder;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
    
    public class BitmapTextFieldBuilder extends DisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private var
            _bitmapText:BitmapFont,
            _text:String;
        
        public function BitmapTextFieldBuilder(layout:Layout = null)
        {
            super(layout);
        }
        
        public function clone():BitmapTextFieldBuilder
        {
            return new BitmapTextFieldBuilder(_layout);
        }
        
        public function initialValue(bitmapText:BitmapFont, text:String):BitmapTextFieldBuilder
        {
            _bitmapText = bitmapText;
            _text = text;
            return this;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var dummyParent:Sprite = new Sprite();
            
            if (_bitmapText && _text)
            {
                dummyParent.addChild(_bitmapText.create(
                    _text,
                    _layout.width.calc(actualParentWidth),
                    _layout.height.calc(actualParentHeight))
                );
                //初期文字列を追加する際は、追加時に実サイズが確定するのでLayoutデータを差し替える.
                _layout = _layout.clone();
                _layout.width.setAtlasTextureSize(dummyParent.width);
                _layout.height.setAtlasTextureSize(dummyParent.height);
            }
            
            dummyParent.name = name;
            Log.info("builded BitmapTextField", name);
            
            return dummyParent;
        }
    }
}