package jp.coremind.view.starling
{
    import jp.coremind.model.Diff;
    import jp.coremind.model.IStorageListener;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.transition.ElementTransition;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.view.IElement;
    import jp.coremind.view.IElementContainer;
    
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
            
            if (parent) parent.removeChild(this);
        }
        
        //IElement interface
        public function initialize(storage:StorageAccessor):void
        {
            _storage = storage;
            _storage.addListener(this);
        }
        
        public function enablePointerDeviceControl():void  {  }
        public function disablePointerDeviceControl():void {  }
        public function get parentElement():IElementContainer { return parent as IElementContainer; }
        public function get elementWidth():Number          { return isNaN(_elementWidth) ? width: _elementWidth; }
        public function get elementHeight():Number         { return isNaN(_elementHeight) ? height: _elementHeight; }
        public function get addTransition():Function       { return ElementTransition.FAST_ADD; }
        public function get mvoeTransition():Function      { return ElementTransition.LINER_MOVE; }
        public function get removeTransition():Function    { return ElementTransition.FAST_REMOVE; }
        public function get storage():StorageAccessor      { return _storage; }
        
        //IStorageListener interface
        public function preview(diff:Diff):void {}
    }
}