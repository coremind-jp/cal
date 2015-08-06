package jp.coremind.view.abstract
{
    public interface IElementContainer extends IElement
    {
        function containsElement(element:IElement):Boolean;
        function addElement(element:IElement):IElement
        function removeElement(element:IElement):IElement;
        function get maxWidth():Number;
        function get maxHeight():Number;
    }
}