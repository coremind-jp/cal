package jp.coremind.view.starling
{
    import jp.coremind.view.IElement;
    import jp.coremind.view.IElementContainer;
    
    import starling.display.DisplayObject;
    
    public class ElementContainer extends Element implements IElementContainer
    {
        public function ElementContainer()
        {
            super();
        }
        
        public function addElement(element:IElement):IElement
        {
            return addChild(element as DisplayObject) as IElement;
        }
        
        public function removeElement(element:IElement):IElement
        {
            return removeChild(element as DisplayObject) as IElement;
        }
        
        public function containsElement(element:IElement):Boolean
        {
            return contains(element as DisplayObject);
        }
    }
}