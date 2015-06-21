package jp.coremind.view.layout
{
    import flash.geom.Point;

    public interface ILayout
    {
        function calcPosition(width:Number, height:Number, index:int, length:int = 0):Point
    }
}