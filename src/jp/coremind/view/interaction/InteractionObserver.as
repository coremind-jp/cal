package jp.coremind.view.interaction
{
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Application;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IDisplayObject;
    
    public class InteractionObserver
    {
        private var _children:Dictionary;
        
        public function InteractionObserver()
        {
        }
        
        public function destroy():void
        {
            if (_children)
            {
                for (var child:* in _children)
                    delete _children[child];
                _children = null;
            }
        }
        
        public function hasInteraction():Boolean
        {
            if (_children)
                for (var child:* in _children)
                    return true;
            
            return false;
        }
        
        protected function addInteraction(child:IDisplayObject, interactionId:String):void
        {
            if (!_children) _children = new Dictionary(true);
            
            if (child in _children)
            {
                Log.warning("Interaction set failed. (already defined child.)");
                return;
            }
        }
        
        protected function getInteraction(child:IDisplayObject):ElementInteraction
        {
            return _children ?
                Application.configure.interaction.getInteraction(_children[child]) as ElementInteraction:
                null;
        }
    }
}