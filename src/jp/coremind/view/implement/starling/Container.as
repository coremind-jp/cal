package jp.coremind.view.implement.starling
{
    import flash.geom.Rectangle;
    
    import jp.coremind.event.ElementEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
    import jp.coremind.view.layout.Layout;
    
    public class Container extends InteractiveElement implements IContainer
    {
        public static const TAG:String = "[Container]";
        Log.addCustomTag(TAG);
        
        protected var
            _maxWidth:Number,
            _maxHeight:Number;
        
        /**
         */
        public function Container(
            layoutCalculator:Layout,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            
            _maxWidth = _maxHeight = NaN;
        }
        
        public function get maxWidth():Number  { return _maxWidth;  };
        public function get maxHeight():Number { return _maxHeight; };
        
        public function updatePosition(x:Number, y:Number):void
        {
            this.x = x;
            this.y = y;
        }
        
        public function enabledClipRect():void
        {
            clipRect = new Rectangle(0, 0, _maxWidth, _maxHeight);
        }
        
        public function disabledClipRect():void
        {
            clipRect = null;
        }
        
        override public function clone():IElement
        {
            Log.warning("can't clone IContainer implement instance.");
            return null;
        }
        
        override protected function _initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            super._initializeElementSize(actualParentWidth, actualParentHeight);
            
            _maxWidth  = _elementWidth;
            _maxHeight = _elementHeight;
        }
        
        override protected function _refreshBackground():void
        {
            if (!_background) return;
            
            _background.width  = _maxWidth;
            _background.height = _maxHeight;
        }
        
        override public function updateElementSize(elementWidth:Number, elementHeight:Number):void
        {
            if (_elementWidth != elementWidth || _elementHeight != elementHeight)
            {
                _elementWidth  = elementWidth;
                _elementHeight = elementHeight;
                
                _updateElementSize();
                
                dispatchEventWith(ElementEvent.UPDATE_SIZE);
            }
        }
        
        protected function _updateElementSize():void {}
        
        public function updateContainerSize(containerWidth:Number, containerHeight:Number):void
        {
            if (_maxWidth != containerWidth || _maxHeight != containerHeight)
            {
                _maxWidth  = containerWidth;
                _maxHeight = containerHeight;
                
                _refreshLayout();
                
                dispatchEventWith(ElementEvent.UPDATE_CONTAINER_SIZE);
            }
        }
    }
}