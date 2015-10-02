package jp.coremind.view.implement.flash.buildin
{
    import flash.text.TextField;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class TextField extends flash.text.TextField implements IDisplayObject
    {
        public function TextField()
        {
            super();
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
    }
}