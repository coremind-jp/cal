package jp.coremind.view.implement.flash
{
    import jp.coremind.core.TransitionTween;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.implement.flash.buildin.Sprite;
    
    public class CalSprite extends Sprite implements ICalSprite
    {
        public function CalSprite(name:String = null)
        {
            super();
            if (name) this.name = name;
        }
        
        public function destroy(withReference:Boolean=false):void
        {
            while (numChildren > 0)
            {
                var child:ICalSprite = removeDisplayAt(0, withReference) as ICalSprite;
                if (child) child.destroy(withReference);
            }
            
            if (parent) parent.removeChild(this);
        }
        
        public function enablePointerDeviceControl():void
        {
            mouseChildren = mouseEnabled = true;
        }
        
        public function disablePointerDeviceControl():void
        {
            mouseChildren = mouseEnabled = false;
        }
        
        public function get addTransition():Function
        {
            return TransitionTween.FAST_ADD;
        }
        
        public function get mvoeTransition():Function
        {
            return TransitionTween.LINER_MOVE;
        }
        
        public function get removeTransition():Function
        {
            return TransitionTween.FAST_REMOVE;
        }
        
        public function get visibleTransition():Function
        {
            return TransitionTween.FAST_VISIBLE;
        }
        
        public function get invisibleTransition():Function
        {
            return TransitionTween.FAST_INVISIBLE;
        }
        
        public function createChildrenNameList():Array
        {
            var result:Array = [];
            
            for (var i:int = 0, len:int = numChildren; i < len; i++) 
                result[i] = getChildAt(i).name;
            
            return result;
        }
    }
}