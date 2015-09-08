package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.transition.ViewTransition;
    
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    
    public class View extends Sprite implements IView
    {
        public function get applicableHistory():Boolean  { return true; }
        
        /**
         * 画面表示オブジェクトクラス.
         * 画面のルートでViewControllerから制御される。
         */
        public function View()
        {
            Log.info("create view", viewName);
        }
        
        protected function get viewName():String
        {
            return null;
        }
        
        public function getElementIndex(element:IElement):int
        {
            return getChildIndex(element as DisplayObject);
        }
        
        public function swapElement(element1:IElement, element2:IElement):void
        {
            return swapChildren(element1 as DisplayObject, element2 as DisplayObject);
        }
        
        public function initialize(r:Routine, t:Thread):void
        {
            if (viewName)
            {
                _buildElement(Application.elementBluePrint.createContentList(viewName));
                r.scceeded();
            }
            else r.failed("'viewName' is null. please set value.");
        }
        
        protected function _buildElement(list:Array):void
        {
            var w:Number = Application.VIEW_PORT.width;
            var h:Number = Application.VIEW_PORT.height;
            
            for (var i:int = 0; i < list.length; i++) 
            {
                var name:String = list[i];
                Log.info("build Element", name, Application.elementBluePrint);
                addChild(Application.elementBluePrint.createBuilder(name).build(name, w, h) as DisplayObject);
            }
        }
        
        public function get addTransition():Function { return ViewTransition.FAST_ADD; }
        
        public function focusInPreProcess(r:Routine, t:Thread):void
        {
            Log.info(viewName, "focusInPreProcess");
            r.scceeded();
        }
        public function get focusInTransition():Function    { return ViewTransition.SKIP; }
        public function focusInPostProcess(r:Routine, t:Thread):void
        {
            Log.info(viewName, "focusInPostProcess");
            r.scceeded();
        }
        
        public function focusOutPreProcess(r:Routine, t:Thread):void
        {
            Log.info(viewName, "focusOutPreProcess");
            r.scceeded();
        }
        public function get focusOutTransition():Function { return ViewTransition.SKIP; }
        public function focusOutPostProcess(r:Routine, t:Thread):void
        {
            Log.info(viewName, "focusOutPostProcess");
            r.scceeded();
        }
        
        public function get removeTransition():Function { return ViewTransition.FAST_REMOVE; }
        public function destroy(r:Routine, t:Thread):void
        {
            Log.info(viewName, "destroy");
            
            while (numChildren > 0)
            {
                var child:IElement = removeChildAt(0, true) as IElement;
                Log.info("isIElement?", Boolean(child));
                if (child) child.destroy(true);
            }
            
            r.scceeded();
        }
    }
}