package jp.coremind.view.implement.starling.buildin
{
    import jp.coremind.view.abstract.IDisplayObject;
    
    import starling.display.MovieClip;
    import starling.textures.Texture;
    
    public class MovieClip extends starling.display.MovieClip implements IDisplayObject
    {
        public function MovieClip(textures:__AS3__.vec.Vector.<starling.textures.Texture>, fps:Number=12)
        {
            super(textures, fps);
        }
    }
}