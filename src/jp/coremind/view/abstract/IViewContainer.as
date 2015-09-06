package jp.coremind.view.abstract
{
    /**
     * ViewContainerクラスで利用するインターフェース.
     */
    public interface IViewContainer
    {
        function get numChildren():int
        function addView(view:IView):void
        function removeView(view:IView):void
        function containsView(view:IView):Boolean
        
        function getViewAt(i:int):IView
        function getViewIndexByClass(cls:Class):int
    }
}