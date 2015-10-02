package jp.coremind.view.implement.flash.buildin
{
    import flash.display.Shape;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class Shape extends flash.display.Shape implements IDisplayObject
    {
        public function Shape()
        {
            super();
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
    }
}