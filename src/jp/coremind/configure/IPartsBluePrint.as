package jp.coremind.configure
{
    import jp.coremind.view.builder.IDisplayObjectBuilder;

    public interface IPartsBluePrint
    {
        function createPartsList(elementClass:Class):Array;
        
        function createBuilder(name:String):IDisplayObjectBuilder;
    }
}