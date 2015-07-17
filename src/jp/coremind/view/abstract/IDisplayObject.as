package jp.coremind.view.abstract
{
    //flash DisplayObject accessor
    public interface IDisplayObject extends IBox
    {
        function set name(v:String):void
        function get name():String
        
        function get alpha():Number;
        function set alpha(n:Number):void;
        
        function get visible():Boolean;
        function set visible(b:Boolean):void;
    }
}