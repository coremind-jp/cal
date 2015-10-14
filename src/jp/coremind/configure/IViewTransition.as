package jp.coremind.configure
{

    public interface IViewTransition
    {
        function get layerType():String;
        function getViewConfigure(layer:String):ViewConfigure;
    }
}