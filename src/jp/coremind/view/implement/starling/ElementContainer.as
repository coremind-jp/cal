package jp.coremind.view.implement.starling
{
    import jp.coremind.event.ElementEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IElementContainer;
    import jp.coremind.view.layout.LayoutCalculator;
    
    import starling.display.DisplayObject;
    
    public class ElementContainer extends InteractiveElement implements IElementContainer
    {
        protected var
            _maxWidth:Number,
            _maxHeight:Number;
        
        public function ElementContainer(
            layoutCalculator:LayoutCalculator,
            controllerClass:Class = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, controllerClass, backgroundBuilder);
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            Log.info("destroy ElementContainer", withReference);
            
            while (numChildren > 0)
            {
                var child:IElement = removeChildAt(0, true) as IElement;
                if (child) child.destroy(withReference);
            }
            
            super.destroy(withReference);
        }
        
        public function refreshChildrenLayout():void {}
        
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
        
        public function get maxWidth():Number  { return _maxWidth;  };
        public function get maxHeight():Number { return _maxHeight; };
        public function initializeChildrenLayout():void {}
        
        override public function updateElementSize(elementWidth:Number, elementHeight:Number):void
        {
            if (_elementWidth != elementWidth || _elementHeight != elementHeight)
            {
                _elementWidth  = elementWidth;
                _elementHeight = elementHeight;
                
                _partsLayout.refresh();
                
                dispatchEventWith(ElementEvent.UPDATE_SIZE);
            }
        }
        
        override public function initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            _maxWidth  = _layoutCalculator.width.calc(actualParentWidth);
            _maxHeight = _layoutCalculator.height.calc(actualParentHeight);
            
            _refreshBackground();
            
            initializeChildrenLayout();
        }
        
        override protected function _refreshBackground():void
        {
            if (_background)
            {
                _background.width  = _maxWidth;
                _background.height = _maxHeight;
            }
        }
    }
}