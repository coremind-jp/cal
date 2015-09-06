package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.implement.starling.buildin.TextField;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    import starling.display.DisplayObject;
    
    public class TextFieldBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private var
            _fontName:String,
            _fontSize:Number,
            _color:uint,
            _bold:Boolean;
        
        public function TextFieldBuilder(width:Size, height:Size, horizontalAlign:Align, verticalAlign:Align,
            fontName:String = "Verdana", fontSize:Number = 12, color:uint = 0, bold:Boolean = false)
        {
            super(width, height, horizontalAlign, verticalAlign);
            
            _fontName = fontName;
            _fontSize = fontSize;
            _color = color;
            _bold = bold;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):DisplayObject
        {
            var tf:TextField = new TextField(
                _width.calc(actualParentWidth),
                _height.calc(actualParentHeight),
                "",
                _fontName,
                _fontSize,
                _color,
                _bold);
            
            tf.name = name;
            //tf.touchable = false;
            Log.info("builded TextField", tf.width, tf.height);
            
            return tf;
        }
    }
}