package jp.coremind.view.implement.starling.buildin
{
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class Image extends starling.display.Image implements IDisplayObject
    {
        public function Image(texture:Texture)
        {
            super(texture);
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
    }
}