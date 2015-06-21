package jp.coremind.view.flash
{
    import flash.display.Sprite;
    
    import jp.coremind.transition.ViewTransition;
    import jp.coremind.view.IElement;
    
    public class Element extends Sprite implements IElement
    {
        protected var
            _data:Object,
            _elementWidth:Number,
            _elementHeight:Number;
        
        public function Element()
        {
            _elementWidth = _elementHeight = NaN;
            super();
        }
        
        public function destroy():void
        {
            _data = null;
            
            filters = null;
            
            if (parent)
                parent.removeChild(this);
        }
        
        public function get data():Object
        {
            return _data;
        }
        
        public function bindData(data:Object):void
        {
            _data = data;
        }
        
        public function get elementWidth():Number
        {
            return isNaN(_elementWidth) ? width: _elementWidth;
        }
        
        public function get elementHeight():Number
        {
            return isNaN(_elementHeight) ? height: _elementHeight;
        }
        
        public function get addTransition():Function { return ViewTransition.FAST_ADD; }
        public function get mvoeTransition():Function; { return ViewTransition.FAST_MOVE; }
        public function get removeTransition():Function { return ViewTransition.FAST_REMOVE; }
    }
}