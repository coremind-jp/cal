package jp.coremind.view.implement.starling
{
    import jp.coremind.control.Controller;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.model.Diff;
    import jp.coremind.model.IStorageListener;
    import jp.coremind.model.StorageModelReader;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IElementContainer;
    import jp.coremind.view.layout.ElementSize;
    import jp.coremind.view.transition.ElementTransition;
    
    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;
    import starling.display.Sprite;
    
    public class Element extends Sprite implements IElement, IRecycle, IStorageListener
    {
        protected var _reader:StorageModelReader;
        
        public function Element()
        {
            touchable = false;
        }
        
        protected function _updateElementSize(w:Number, h:Number):void
        {
            ElementSize.registry($.getClassByInstance(this), w, h);
            dispatchEventWith(ElementEvent.UPDATE_SIZE);
        }
        
        public function initialize(reader:StorageModelReader):void
        {
            if (reader)
            {
                _reader = reader;
                _reader.addListener(this);
                
                _initializeRuntimeModel();
            }
        }
        
        protected function _initializeRuntimeModel():void
        {
        }
        
        public function reset():void
        {
            if (_reader)
                _reader.removeListener(this);
        }
        
        public function destroy():void
        {
            if (_reader)
            {
                _reader.removeListener(this);
                _reader = null;
            }
            
            removeFromParent(true);
        }
        
        public function getChildByPath(path:String):DisplayObject
        {
            var hierarchy:Array = path.split(".");
            var container:DisplayObjectContainer = this;
            var child:DisplayObject = null;
            
            for (var i:int, len:int = hierarchy.length; i < len; i++)
            {
                var key:String = hierarchy[i];
                child = container.getChildByName(key);
                
                if (i != len-1)
                {
                    container = child as DisplayObjectContainer;
                    if (!container)
                    {
                        Log.error("[Element] failed getChildByPath.", key, "is not DisplayObjectContainer. hierarchy=", hierarchy);
                        continue;
                    }
                }
            }
            
            return child;
        }
        
        public function addListener(type:String, listener:Function):void    { addEventListener(type, listener); }
        public function removeListener(type:String, listener:Function):void { removeEventListener(type, listener); }
        public function hasListener(type:String):void { hasEventListener(type); }
        
        public function enablePointerDeviceControl():void  {}
        public function disablePointerDeviceControl():void {}
        
        public function get elementWidth():Number          { return ElementSize.getWidth($.getClassByInstance(this),  width); }
        public function get elementHeight():Number         { return ElementSize.getHeight($.getClassByInstance(this), height); }
        public function get controller():Controller        { return Controller.getInstance(Controller); }
        
        public function get addTransition():Function       { return ElementTransition.FAST_ADD; }
        public function get mvoeTransition():Function      { return ElementTransition.LINER_MOVE; }
        public function get removeTransition():Function    { return ElementTransition.FAST_REMOVE; }
        public function get visibleTransition():Function   { return ElementTransition.FAST_VISIBLE; }
        public function get invisibleTransition():Function { return ElementTransition.FAST_INVISIBLE; }
        
        public function get parentElement():IElementContainer { return parent as IElementContainer; }
        
        //IStorageListener interface
        public function refresh():void {}
        public function preview(plainDiff:Diff):void {}
        public function commit(plainDiff:Diff):void {}
    }
}