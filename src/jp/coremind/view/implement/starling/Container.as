package jp.coremind.view.implement.starling
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.IBackgroundBuilder;
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
        }
        
        public function get maxWidth():Number  { return _maxWidth;  };
        public function get maxHeight():Number { return _maxHeight; };
        
        public function updatePosition(x:Number, y:Number):void
        {
            this.x = x;
            this.y = y;
        }
        
        override public function clone():IElement
        {
            Log.warning("can't clone IContainer implement instance.");
            return null;
        }
        
        override protected function _initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            _maxWidth  = _elementWidth  = _layout.width.calc(actualParentWidth);
            _maxHeight = _elementHeight = _layout.height.calc(actualParentHeight);
            
            x = _layout.horizontalAlign.calc(actualParentWidth, _maxWidth);
            y = _layout.verticalAlign.calc(actualParentHeight, _maxHeight);
            
            Log.custom(TAG,
                "initializeElementSize actualSize:", actualParentWidth, actualParentHeight,
                "elementSize:", _elementWidth, _elementHeight,
                "position:", x, y);
            
            if (!_partsLayout.isBuildedParts())
                 _partsLayout.buildParts();
            
            _refreshLayout(_maxWidth, _maxHeight);
        }
    }
}