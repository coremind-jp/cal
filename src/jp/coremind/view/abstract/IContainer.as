package jp.coremind.view.abstract
{
    public interface IContainer extends IElement
    {
        function get maxWidth():Number;
        function get maxHeight():Number;
        
        function get interactionId():String;
        function set interactionId(id:String):void;
        
        function updatePosition(x:Number, y:Number):void;
    }
}