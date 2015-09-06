package jp.coremind.view.abstract
{
    public interface IElementContainer extends IElement
    {
        function containsElement(element:IElement):Boolean;
        function addElement(element:IElement):IElement
        function removeElement(element:IElement):IElement;
        
        /**
         * 内包する子の描画状態を更新する.
         */
        function refreshChildrenLayout():void;
        
        function get maxWidth():Number;
        function get maxHeight():Number;
    }
}