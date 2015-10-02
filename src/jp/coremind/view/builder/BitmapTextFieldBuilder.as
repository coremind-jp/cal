package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    public class BitmapTextFieldBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        public function BitmapTextFieldBuilder(width:Size, height:Size, horizontalAlign:Align, verticalAlign:Align)
        {
            super(width, height, horizontalAlign, verticalAlign);
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var sprite:Sprite = new Sprite();
            
            sprite.name = name;
            Log.info("builded BitmapTextField");
            
            return sprite;
        }
    }
}