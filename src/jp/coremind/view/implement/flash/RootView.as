package jp.coremind.view.implement.flash
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.abstract.IViewContainer;
    
    public class RootView extends Sprite implements IViewContainer
    {
        public function RootView()
        {
            super();
        }
        
        public function addView(view:IView):void         { super.addChild(view as DisplayObject); }
        public function removeView(view:IView):void      { super.removeChild(view as DisplayObject); }
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
    }
}