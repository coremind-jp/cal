package jp.coremind.view
{
    public interface IElement
    {
        function bindData(data:Object):void;
        function get data():Object;
        function destroy():void;
        
        function set name(v:String):void
        function get name():String
        
        function get x():Number;
        function set x(n:Number):void;
        
        function get y():Number;
        function set y(n:Number):void;
        
        function get width():Number;
        function set width(n:Number):void;
        
        function get height():Number;
        function set height(n:Number):void;
        
        function containsElement(element:IElement):Boolean;
        
        function get elementWidth():Number;
        function get elementHeight():Number;
        
        function get addTransition():Function;
        function get mvoeTransition():Function;
        function get removeTransition():Function;
    }
}