package jp.coremind.view.layout
{
    import flash.geom.Rectangle;

    public interface ILayout
    {
        function destroy():void;
        
        function getElementClass(index:int):Class;
        
        function calcElementRect(
            parentWidth:Number,
            parentHeight:Number,
            index:int,
            length:int = 0):Rectangle;
        
        function calcTotalRect(
            parentWidth:Number,
            parentHeight:Number,
            index:int,
            length:int = 0):Rectangle
    }
}