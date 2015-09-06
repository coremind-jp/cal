package jp.coremind.view.builder
{
    import jp.coremind.view.layout.LayoutCalculator;
    
    import starling.display.DisplayObject;

    public interface IDisplayObjectBuilder
    {
        function build(name:String, actualParentWidth:int, actualParentHeight:int):DisplayObject;
        function requestLayoutCalculator():LayoutCalculator;
    }
}