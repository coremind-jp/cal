package jp.coremind.view.implement.starling
{
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    import starling.textures.Texture;
    
    public class BackgroundImage extends Image implements IStretchBox
    {
        public function BackgroundImage(texture:Texture)
        {
            super(texture);
        }
        
        public function destroy(withReference:Boolean = false):void
        {
        }
    }
}