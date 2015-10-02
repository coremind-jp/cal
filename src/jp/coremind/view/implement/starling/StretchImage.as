package jp.coremind.view.implement.starling
{
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    import starling.textures.Texture;
    
    public class StretchImage extends Image implements IStretchBox
    {
        public function StretchImage(texture:Texture)
        {
            super(texture);
        }
    }
}