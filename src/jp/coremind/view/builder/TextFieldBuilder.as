package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.buildin.TextField;
    import jp.coremind.view.layout.Layout;
    
    public class TextFieldBuilder extends DisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private var
            _text:String,
            _fontName:String,
            _fontSize:Number,
            _color:uint,
            _bold:Boolean;
        
        public function TextFieldBuilder(
            layout:Layout = null,
            fontName:String = "Verdana",
            fontSize:Number = 12,
            color:uint = 0,
            bold:Boolean = false)
        {
            super(layout);
            
            _fontName = fontName;
            _fontSize = fontSize;
            _color = color;
            _bold = bold;
        }
        
        public function clone():TextFieldBuilder
        {
            return new TextFieldBuilder(_layout, _fontName, _fontSize, _color, _bold);
        }
        
        public function initialValue(text:String):TextFieldBuilder
        {
            _text = text;
            return this;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var tf:TextField = new TextField(
                _layout.width.calc(actualParentWidth),
                _layout.width.calc(actualParentHeight),
                "", _fontName, _fontSize, _color, _bold);
            
            tf.name = name;
            if (_text) tf.text = _text;
            Log.info("builded TextField", tf.width, tf.height, tf.text);
            
            return tf;
        }
    }
}