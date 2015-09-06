package jp.coremind.view.builder
{

    public interface IElementBluePrint
    {
        function createNavigationList(viewName:String):Array;
        
        function createPopupList(viewName:String):Array;
        
        function createContentList(viewName:String):Array;
        
        function createPartsList(elementClass:Class):Array;
        
        function createBuilder(name:String):IDisplayObjectBuilder;
    }
}