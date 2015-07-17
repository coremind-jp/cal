package jp.coremind.view.abstract
{
    public interface IBox
    {
        function get x():Number;
        function set x(n:Number):void;
        
        function get y():Number;
        function set y(n:Number):void;
        
        function get width():Number;
        function set width(n:Number):void;
        
        function get height():Number;
        function set height(n:Number):void;
        
        function get scaleX():Number;
        function set scaleX(n:Number):void;
        
        function get scaleY():Number;
        function set scaleY(n:Number):void;
    }
}