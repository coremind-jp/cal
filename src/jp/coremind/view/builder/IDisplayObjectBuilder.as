package jp.coremind.view.builder
{
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.layout.LayoutCalculator;
    
    public interface IDisplayObjectBuilder
    {
        function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox;
        function requestLayoutCalculator():LayoutCalculator;
    }
}