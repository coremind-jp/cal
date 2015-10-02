package jp.coremind.view.implement.starling
{
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.control.Controller;
    import jp.coremind.core.Application;
    import jp.coremind.event.ViewTransitionEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.ICalSprite;
    
    public class NavigationView extends View
    {
        private static const TAG:String = "[StarlingNavigation]";
        Log.addCustomTag(TAG);
        
        public static const NAME:String = "StarlingNavigation";
        
        public function NavigationView()
        {
            super(NAME);
            
            Application.globalEvent.addEventListener(ViewTransitionEvent.BEGIN_TRANSITION, partsRefresh);
        }
        
        override public function initializeProcess(r:Routine, t:Thread):void { r.scceeded(); }
        
        public function partsRefresh(e:ViewTransitionEvent):void
        {
            var pId:String = "partsRefresh "　+　e.next;
            var destroyList:Array = _createChildList();
            
            _addNavigationParts(pId, destroyList, e.next);
            _removeNavigationParts(pId, destroyList);
            
            Controller.getInstance().syncProcess.run(pId, function(p:Process):void
            {
                while (destroyList.length > 0) 
                {
                    var child:ICalSprite = destroyList.shift() as ICalSprite;
                    if (child) child.destroy(true);
                }
            });
        }
        
        private function _createChildList():Array
        {
            var result:Array = [];
            
            for (var i:int = 0, len:int = numChildren; i < len; i++) 
                result[i] = getChildAt(i).name;
            
            return result;
        }
        
        private function _addNavigationParts(pId:String, destroyList:Array, nextView:String):void
        {
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            var addList:Array = bluePrint.createNavigationList(nextView);
            
            if (addList.length == 0)
                return;
            
            var thread:Thread = new Thread("addNavigationParts");
            while (addList.length > 0) 
            {
                var childName:String = addList.shift();
                var child:ICalSprite = getDisplayByName(childName) as ICalSprite;
                
                if (child) Log.custom(TAG, childName, "skip build. (already builded)");
                else
                {
                    Log.custom(TAG, childName, "build exec.");
                    
                    child = bluePrint.createBuilder(childName).build(childName, Application.VIEW_PORT.width, Application.VIEW_PORT.height) as ICalSprite;
                    thread.pushRoutine(child.addTransition(this, child));
                }
                
                var n:int = destroyList.indexOf(childName);
                if (n != -1) destroyList.splice(n, 1);
            }
            
            Controller.getInstance().syncProcess.pushThread(pId, thread, true, true);
        }
        
        private function _removeNavigationParts(pId:String, destroyList:Array):void
        {
            if (destroyList.length == 0)
                return;
            
            var thread:Thread  = new Thread("removeNavigationParts");
            for (var i:int = 0; i < destroyList.length; i++) 
            {
                Log.custom(TAG, destroyList[i], "remove.");
                
                var child:ICalSprite = getDisplayByName(destroyList[i]) as ICalSprite;
                if (child)
                {
                    destroyList[i] = child;
                    thread.pushRoutine(child.removeTransition(this, child));
                }
            }
            
            Controller.getInstance().syncProcess.pushThread(pId, thread, true, true);
        }
    }
}