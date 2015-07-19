package jp.coremind.view.implement.starling
{
    import jp.coremind.event.ElementEvent;
    import jp.coremind.model.Diff;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.model.storage.IStorageListener;
    import jp.coremind.view.transition.ElementTransition;
    import jp.coremind.data.IRecycle;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IElementContainer;
    
    import starling.display.Sprite;
    
    public class Element extends Sprite implements IElement, IStorageListener, IRecycle
    {
        protected var
            _storage:StorageAccessor,
            
            _elementWidth:Number,
            _elementHeight:Number;
        
        public function Element()
        {
            _elementWidth = _elementHeight = NaN;
            touchable = false;
        }
        
        protected function _updateElementSize(w:Number, h:Number):void
        {
            _elementWidth  = w;
            _elementHeight = h;
            //Log.info("_updateElementSize width", w, "height", h);
            dispatchEventWith(ElementEvent.UPDATE_SIZE);
        }
        
        //IRecycle interface
        public function reuseInstance():void
        {
            if (_storage)
                _storage.addListener(this);
        }
        
        //IRecycle interface
        public function resetInstance():void
        {
            if (_storage)
                _storage.removeListener(this);
        }
        
        //IElement interface
        public function destroy():void
        {
            if (_storage)
            {
                _storage.updateParentModel(null);
                _storage.removeListener(this);
                _storage = null;
            }
            
            removeFromParent(true);
        }
        
        //IElement interface
        public function initialize(storage:StorageAccessor):void
        {
            if (storage)
            {
                _storage = storage;
                _storage.addListener(this);
            }
        }
        
        public function addListener(type:String, listener:Function):void    { addEventListener(type, listener); }
        public function removeListener(type:String, listener:Function):void { removeEventListener(type, listener); }
        public function hasListener(type:String):void { hasEventListener(type); }
        
        public function enablePointerDeviceControl():void  { touchable = false; }
        public function disablePointerDeviceControl():void { touchable = false; }
        public function get parentElement():IElementContainer { return parent as IElementContainer; }
        public function get elementWidth():Number          { return isNaN(_elementWidth) ? width: _elementWidth; }
        public function get elementHeight():Number         { return isNaN(_elementHeight) ? height: _elementHeight; }
        public function get addTransition():Function       { return ElementTransition.FAST_ADD; }
        public function get mvoeTransition():Function      { return ElementTransition.LINER_MOVE; }
        public function get removeTransition():Function    { return ElementTransition.FAST_REMOVE; }
        public function get visibleTransition():Function   { return ElementTransition.FAST_VISIBLE; }
        public function get invisibleTransition():Function { return ElementTransition.FAST_INVISIBLE; }

        public function get storage():StorageAccessor      { return _storage; }
        
        //IStorageListener interface
        public function refresh():void {}
        public function preview(plainDiff:Diff):void {}
        public function commit(plainDiff:Diff):void {}
    }
}