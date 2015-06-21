package jp.coremind.view
{
    public interface IElementContainer extends IElement
    {
        function addElement(element:IElement):IElement
        function removeElement(element:IElement):IElement;
    }
}