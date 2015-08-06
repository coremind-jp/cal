package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IElementContainer;
    
    import starling.display.DisplayObject;
    
    public class ElementContainer extends InteractiveElement implements IElementContainer
    {
        protected var
            _elementWidth:Number,
            _elementHeight:Number,
            _maxWidth:Number,
            _maxHeight:Number;
        
        public function ElementContainer(maxWidth:Number = NaN, maxHeight:Number = NaN)
        {
            super();
            
            _elementWidth  = _maxWidth  = isNaN(maxWidth)  ? Application.stage.stageWidth : maxWidth;
            _elementHeight = _maxHeight = isNaN(maxHeight) ? Application.stage.stageHeight: maxHeight;
        }
        
        override protected function _updateElementSize(w:Number, h:Number):void
        {
            _elementWidth  = w;
            _elementHeight = h;
            dispatchEventWith(ElementEvent.UPDATE_SIZE);
        }
        
        public function addElement(element:IElement):IElement
        {
            return addChild(element as DisplayObject) as IElement;
        }
        
        public function removeElement(element:IElement):IElement
        {
            return removeChild(element as DisplayObject) as IElement;
        }
        
        public function containsElement(element:IElement):Boolean
        {
            return contains(element as DisplayObject);
        }
        
        public function getElementByPath(path:String):IElement
        {
            var e:IElement = getChildByPath(path) as IElement;
            if (e) return e;
            else
            {
                Log.error("[ElementContainer] failed getElementByPath.", path, "is not IElement Object.");
                return null;
            }
        }
        
        override public function get elementWidth():Number    { return _elementWidth; }
        override public function get elementHeight():Number   { return _elementHeight; }
        public function get maxWidth():Number  { return _maxWidth;  };
        public function get maxHeight():Number { return _maxHeight; };
    }
}