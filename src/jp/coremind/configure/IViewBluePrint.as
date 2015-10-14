package jp.coremind.configure
{
    public interface IViewBluePrint
    {
        function createBuilder(name:String):ViewBuilder;
    }
}