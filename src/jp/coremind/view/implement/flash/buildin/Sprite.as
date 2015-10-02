package jp.coremind.view.implement.flash.buildin
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class Sprite extends flash.display.Sprite implements IDisplayObject
    {
        public function Sprite()
        {
            super();
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
        
        public function addDisplay(child:IDisplayObject):IDisplayObject
        {
            return addChild(child as DisplayObject) as IDisplayObject;
        }
        
        public function addDisplayAt(child:IDisplayObject, index:int):IDisplayObject
        {
            return addChildAt(child as DisplayObject, index) as IDisplayObject;
        }
        
        public function containsDisplay(child:IDisplayObject):Boolean
        {
            return contains(child as DisplayObject);
        }
        
        public function getDisplayAt(index:int):IDisplayObject
        {
            return getChildAt(index) as IDisplayObject;
        }
        
        public function getDisplayByName(name:String):IDisplayObject
        {
            return getChildByName(name) as IDisplayObject;
        }
        
        public function getDisplayIndex(child:IDisplayObject):int
        {
            return getChildIndex(child as DisplayObject);
        }
        
        public function getDisplayIndexByClass(cls:Class):int
        {
            for (var i:int = 0, len:int = numChildren; i < len; i++) 
                if ($.getClassByInstance(getChildAt(i)) === cls) return i;
            return -1;
        }
        
        public function removeDisplay(child:IDisplayObject, dispose:Boolean = false):IDisplayObject
        {
            return removeChild(child as DisplayObject) as IDisplayObject;
        }
        
        public function removeDisplayAt(index:int, dispose:Boolean = false):IDisplayObject
        {
            return removeChildAt(index) as IDisplayObject;
        }
        
        public function removeDisplays(beginIndex:int=0, endIndex:int=0x7fffffff, dispose:Boolean = false):void
        {
            removeChildren(beginIndex, endIndex);
        }
        
        public function setDisplayIndex(child:IDisplayObject, index:int):void
        {
            setChildIndex(child as DisplayObject, index);
        }
        
        public function swapDisplays(child1:IDisplayObject, child2:IDisplayObject):void
        {
            swapChildren(child1 as DisplayObject, child2 as DisplayObject);
        }
    }
}