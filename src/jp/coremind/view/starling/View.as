package jp.coremind.view.starling
{
    import jp.coremind.control.Routine;
    import jp.coremind.control.Thread;
    import jp.coremind.transition.ViewTransition;
    import jp.coremind.utility.Log;
    import jp.coremind.view.IView;
    import jp.coremind.view.IViewContainer;
    
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    
    public class View extends Sprite implements IViewContainer
    {
        public function get naviConfigure():Object  { return {}; }
        public function get viewConfigure():Object  { return {}; }
        public function get applicableHistory():Boolean  { return true; }
        
        public function View()
        {
            Log.info(name+" "+ this +" "+" create");
        }
        
        public function addView(view:IView):void         { addChild(view as DisplayObject); }
        public function removeView(view:IView):void      { removeChild(view as DisplayObject); }
        public function containsView(view:IView):Boolean { return super.contains(view as DisplayObject); }
        public function getViewIndexByClass(cls:Class):int
        {
            for (var i:int = numChildren - 1; 0 <= i; i--) 
                if (Object(getChildAt(i)).constructor === cls)
                    return i;
            return -1;
        }
        public function getViewAt(i:int):IView
        {
            return 0 <= i && i < numChildren ? getChildAt(i) as IView: null;
        }
        
        public function initialize(r:Routine, t:Thread):void
        {
            r.scceeded();
        }
        public function get addTransition():Function { return ViewTransition.FAST_ADD; }
        
        public function focusInPreProcess(r:Routine, t:Thread):void
        {
            Log.info(name+"focusInPreProcess");
            r.scceeded();
        }
        public function get focusInTransition():Function    { return ViewTransition.SKIP; }
        public function focusInPostProcess(r:Routine, t:Thread):void
        {
            Log.info(name+"focusInPostProcess");
            r.scceeded();
        }
        
        public function focusOutPreProcess(r:Routine, t:Thread):void
        {
            Log.info(name+"focusOutPreProcess");
            r.scceeded();
        }
        public function get focusOutTransition():Function { return ViewTransition.SKIP; }
        public function focusOutPostProcess(r:Routine, t:Thread):void
        {
            Log.info(name+"focusOutPostProcess");
            r.scceeded();
        }
        
        public function get removeTransition():Function { return ViewTransition.FAST_REMOVE; }
        public function destroy(r:Routine, t:Thread):void
        {
            Log.info(name+"destroy");
            r.scceeded();
        }
    }
}