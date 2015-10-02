package jp.coremind.view.abstract
{
    //flash DisplayObject accessor
    public interface IDisplayObject extends IBox
    {
        function get parentDisplay():IDisplayObjectContainer;
        
        function set name(v:String):void
        function get name():String
        
        function get alpha():Number;
        function set alpha(n:Number):void;
        
        function set visible(b:Boolean):void;
        function get visible():Boolean;
    }
}