package jp.coremind.view
{
    import jp.coremind.control.Process;

    public interface ILayerControl
    {
        function get numChildren():int
        function getViewIndexByClass(cls:Class):int
        function bindPush(p:Process, next:IView, parallel:Boolean = false):void
        function bindPop(p:Process, parallel:Boolean = false):void
        function bindSwap(p:Process, i:int, parallel:Boolean = false):void
        function bindReset(p:Process, cls:*, parallel:Boolean = false):void
        function bindReplace(p:Process, v:IView, parallel:Boolean = false):void
    }
}