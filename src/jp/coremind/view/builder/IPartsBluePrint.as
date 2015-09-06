package jp.coremind.view.builder
{

    public interface IPartsBluePrint
    {
        function createPartsList(elementClass:Class):Array;
        
        function createBuilder(name:String):IDisplayObjectBuilder;
    }
}