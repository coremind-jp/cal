package jp.coremind.view.implement.flash.buildin
{
    import flash.display.MovieClip;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class MovieClip extends flash.display.MovieClip implements IDisplayObject
    {
        public function MovieClip()
        {
            super();
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
    }
}