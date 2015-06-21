package jp.coremind.transition
{
    import jp.coremind.control.Routine;
    import jp.coremind.control.Thread;
    import jp.coremind.utility.Log;
    import jp.coremind.view.IView;
    import jp.coremind.view.IViewContainer;

    public class ViewTransition
    {
        private static const _SKIP:Function = function(p:Routine, t:Thread):void { p.scceeded(); };
        
        public static function FAST_ADD(container:IViewContainer, view:IView):Function
        {
            return function(p:Routine, t:Thread):void
            {
                Log.info(container, view);
                if (container && view)
                {
                    container.addView(view);
                    p.scceeded();
                }
                else p.failed("undefined container or view. container:" + container + " view:" + view);
            }
        }
        
        public static function FAST_REMOVE(container:IViewContainer, view:IView):Function
        {
            return function(p:Routine, t:Thread):void
            {
                if (container && view)
                {
                    if (container.containsView(view))
                    {
                        container.removeView(view);
                        p.scceeded();
                    }
                    else p.failed("not contains view. " + view.name);
                }
                else p.failed("undefined container or view. container:" + container + " view:" + view);
            }
        }
        
        public static function SKIP(container:IViewContainer, view:IView):Function
        {
            return _SKIP;
        }
    }
}