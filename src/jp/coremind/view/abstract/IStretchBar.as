package jp.coremind.view.abstract
{
    public interface IStretchBar
    {
        function destroy(withReference:Boolean = true):void;
        function get direction():String;
        
        function get size():Number;
        function set size(value:Number):void;
    }
}