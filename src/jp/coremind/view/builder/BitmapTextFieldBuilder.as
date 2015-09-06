package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    import starling.display.DisplayObject;
    
    public class BitmapTextFieldBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        public function BitmapTextFieldBuilder(width:Size, height:Size, horizontalAlign:Align, verticalAlign:Align)
        {
            super(width, height, horizontalAlign, verticalAlign);
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):DisplayObject
        {
            var sprite:Sprite = new Sprite();
            
            sprite.name = name;
            //sprite.touchable = false;
            Log.info("builded BitmapTextField", sprite.width, sprite.height);
            
            return sprite;
        }
    }
}