package jp.coremind.view.abstract
{
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;

    public interface IView
    {
        function set x(v:Number):void
        function get x():Number
        
        function set y(v:Number):void
        function get y():Number
        
        function set width(v:Number):void
        function get width():Number
        
        function set height(v:Number):void
        function get height():Number
        
        function set name(v:String):void
        function get name():String
        
        function getElementIndex(child:IElement):int;
        
        function get applicableHistory():Boolean;
        
        function initialize(p:Routine, t:Thread):void;
        function get addTransition():Function;
        
        function focusInPreProcess(p:Routine, t:Thread):void;
        function get focusInTransition():Function;
        function focusInPostProcess(p:Routine, t:Thread):void;
        
        function focusOutPreProcess(p:Routine, t:Thread):void;
        function get focusOutTransition():Function;
        function focusOutPostProcess(p:Routine, t:Thread):void;
        
        function get removeTransition():Function;
        function destroy(p:Routine, t:Thread):void;
    }
}