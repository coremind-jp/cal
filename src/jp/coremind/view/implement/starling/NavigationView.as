package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.INavigationView;
    
    import starling.display.DisplayObject;
    
    public class NavigationView extends View implements INavigationView
    {
        public function NavigationView()
        {
            super();
        }
        
        override protected function get viewName():String
        {
            return "Navigation";
        }
        
        override public function initialize(r:Routine, t:Thread):void
        {
            _buildElement(Application.elementBluePrint.createNavigationList(viewName));
            r.scceeded();
        }
        
        public function refresh(viewName:String):void
        {
            var navigationList:Array = Application.elementBluePrint.createNavigationList(viewName);
            Log.info("build navigation list", navigationList);
            var childList:Array = _createChildList();
            var w:Number = Application.VIEW_PORT.width;
            var h:Number = Application.VIEW_PORT.height;
            var i:int = 0;
            
            while (navigationList.length > 0) 
            {
                var navigationName:String = navigationList.shift();
                var element:IElement = getChildByName(navigationName) as IElement;
                Log.info("build navigation?", element ? "no. already builded": "yes.");
                
                if (element)
                {
                    if (getElementIndex(element) != i)
                        swapElement(element, getChildAt(i++) as IElement);
                }
                else
                {
                    addChildAt(
                        Application.elementBluePrint.createBuilder(navigationName).build(navigationName, w, h) as DisplayObject,
                        i++);
                }
                
                var n:int = childList.indexOf(navigationName);
                if (n != -1) childList.splice(n, 1);
            }
            
            while (childList.length > 0) 
            {
                var child:DisplayObject = getChildByName(childList.shift());
                
                removeChild(child);
                
                if (child is IElement)
                   (child as IElement).destroy();
            }
        }
        
        private function _createChildList():Array
        {
            var result:Array = [];
            
            for (var i:int = 0, len:int = numChildren; i < len; i++) 
                result[i] = getChildAt(i).name;
            
            return result;
        }
    }
}