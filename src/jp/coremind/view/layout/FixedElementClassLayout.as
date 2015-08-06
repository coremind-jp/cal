package jp.coremind.view.layout
{
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.Log;
    
    public class FixedElementClassLayout extends AbstractLayout
    {
        protected var
            _elementClass:Class,
            _elementWidth:Number,
            _elementHeight:Number;
        
        public function FixedElementClassLayout(elementClass:Class, temporaryRect:Rectangle)
        {
            super(temporaryRect);
            
            _elementClass  = _elementClass;
            _elementWidth  = ElementSize.getWidth(elementClass, NaN);
            _elementHeight = ElementSize.getHeight(elementClass, NaN);
            
            if (isNaN(_elementWidth) || isNaN(_elementHeight))
                Log.error("[FixedElementLayout] ", _elementClass, "is not registry in 'ElementSize'. please registry to 'ElementSize'");
        }
        
        public function getElementClass(index:int):Class
        {
            return _elementClass;
        }
    }
}