package jp.coremind.view.abstract
{
    public interface IContainer extends IElement
    {
        function get maxWidth():Number;
        function get maxHeight():Number;
        
        function updatePosition(x:Number, y:Number):void;
    }
}