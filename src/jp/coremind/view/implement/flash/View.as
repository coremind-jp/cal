package jp.coremind.view.implement.flash
{
    import flash.display.DisplayObject;
    
    import jp.coremind.core.Application;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.implement.flash.buildin.Sprite;
    import jp.coremind.view.implement.starling.component.ScrollContainer;
    import jp.coremind.view.transition.ViewTransition;
    
    public class View extends Sprite implements IView
    {
        public function get naviConfigure():Object  { return {}; }
        public function get viewConfigure():Object  { return {}; }
        public function get applicableHistory():Boolean  { return true; }
        
        public function View()
        {
            Log.info(name+" "+ this +" "+" create");
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
                _buildBluePrint(Application.elementBluePrint.createNavigationList(viewName));
                r.scceeded();
            }
            else r.failed("'viewName' is null. please set value.");
        }
        
        protected function _buildBluePrint(list:Array):void
        {
            var w:Number = Application.VIEW_PORT.width;
            var h:Number = Application.VIEW_PORT.height;
            
            for (var i:int = 0; i < list.length; i++) 
            {
                var name:String = list[i];
                /** TODO FlashAPI用Builderがまだない */
                //addChild(Application.elementBuilder.createBuilder(name).build(name, w, h));
            }
        }
        
        protected function _initializeStorageModel(r:Routine, element:IElement):void
        {
            var storageId:String = element.controller.initializeStorageModel(element.name);
            
            storageId === null ?
                r.failed("undefined StorageConfigure. instance '"+element.name+"'"):
                element.initialize(storageId);
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