package jp.coremind.configure
{
    import jp.coremind.view.builder.IDisplayObjectBuilder;

    public interface IPartsBluePrint
    {
        function createPartsListByClass(cls:Class):Array;
        
        function createPartsListByName(name:String):Array;
        
        function createBuilder(name:String):IDisplayObjectBuilder;
    }
}