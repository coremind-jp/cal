package jp.coremind.view.flash
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.model.Diff;
    import jp.coremind.model.storage.IStorageListener;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.view.transition.ElementTransition;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.view.IElement;
    import jp.coremind.view.IElementContainer;
    
    public class Element extends Sprite implements IElement, IStorageListener, IRecycle
    {
        private static const INITIAL_POINT:Point = new Point();
        
        protected var
            _storage:StorageAccessor,
            
            _parent:DisplayObjectContainer,
            _global:Point,
            
            _elementWidth:Number,
            _elementHeight:Number;
        
        public function Element()
        {
            _global = INITIAL_POINT;
            _elementWidth = _elementHeight = NaN;
            addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        }
        
        private function _onAddedToStage(e:Event):void
        {
            _global = localToGlobal(INITIAL_POINT);
        }
        
        public function containsDrawableArea(global:Point):Boolean
        {
            var _x:Number = global.x + x;
            var _y:Number = global.y + y;
            
            return  _x + width  < 0 || Application.stage.stageWidth  < _x
                ||  _y + height < 0 || Application.stage.stageHeight < _y;
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
            _storage.removeListener(this);
        }
        
        //IElement interface
        public function destroy():void
        {
            removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
            
            if (_storage)
            {
                _storage.updateParentModel(null);
                _storage.removeListener(this);
                _storage = null;
            }
            
            filters = null;
            
            if (parentElement) parentElement.removeElement(this);
        }
        
        //IElement interface
        public function initialize(storage:StorageAccessor):void
        {
            _storage = storage;
            _storage.addListener(this);
        }
        
        public function addListener(type:String, listener:Function):void    { addEventListener(type, listener); }
        public function removeListener(type:String, listener:Function):void { removeEventListener(type, listener); }
        public function hasListener(type:String):void { hasEventListener(type); }
        
        public function enablePointerDeviceControl():void  { mouseChildren = mouseEnabled = true; }
        public function disablePointerDeviceControl():void { mouseChildren = mouseEnabled = false; }
        public function get parentElement():IElementContainer { return parent as IElementContainer; }
        public function get elementWidth():Number          { return isNaN(_elementWidth) ? width: _elementWidth; }
        public function get elementHeight():Number         { return isNaN(_elementHeight) ? height: _elementHeight; }
        public function get addTransition():Function       { return ElementTransition.FAST_ADD; }
        public function get mvoeTransition():Function      { return ElementTransition.FAST_MOVE; }
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