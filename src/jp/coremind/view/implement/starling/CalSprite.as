package jp.coremind.view.implement.starling
{
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
        
        public function createChildrenNameList():Array
        {
            var result:Array = [];
            
            for (var i:int = 0, len:int = numChildren; i < len; i++) 
                result[i] = getChildAt(i).name;
            
            return result;
        }
    }
}