package jp.coremind.view.builder
{
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.layout.Layout;
    
    public interface IDisplayObjectBuilder
    {
        function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox;
        
        function get layout():Layout;
    }
}