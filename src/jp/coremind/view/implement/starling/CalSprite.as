package jp.coremind.view.implement.starling
{
    import jp.coremind.core.TransitionTween;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    
    public class CalSprite extends Sprite implements ICalSprite
    {
        public function CalSprite(name:String = null)
        {
            super();
            this.name = name;
            alpha = .999999;
        }
        
        public function destroy(withReference:Boolean = false):void
        {
            while (numChildren > 0)
            {
                var child:ICalSprite = removeDisplayAt(0, withReference) as ICalSprite;
                if (child) child.destroy(withReference);
            }
            
            if (parent) removeFromParent(withReference);
        }
        
        public function enablePointerDeviceControl():void
        {
            touchable = true;
        }
        
        public function disablePointerDeviceControl():void
        {
            touchable = false;
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