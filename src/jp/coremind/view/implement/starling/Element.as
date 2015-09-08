package jp.coremind.view.implement.starling
{
    import jp.coremind.control.Controller;
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.model.Diff;
    import jp.coremind.model.ElementModelId;
    import jp.coremind.model.IStorageListener;
    import jp.coremind.model.StorageModelReader;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IElementContainer;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.abstract.component.Grid9;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    import jp.coremind.view.layout.LayoutCalculator;
    import jp.coremind.view.layout.PartsLayout;
    import jp.coremind.view.transition.ElementTransition;
    
    import starling.display.DisplayObject;
    
    public class Element extends Sprite implements IElement, IRecycle, IStorageListener
    {
        private static const UNDEFINED_LAYOUT_CALCULATOR:LayoutCalculator = new LayoutCalculator();
        
        protected var
            _reader:StorageModelReader,
            _controller:Class,
            _layoutCalculator:LayoutCalculator,
            _elementId:ElementModelId,
            _elementWidth:Number,
            _elementHeight:Number,
            _isCreatedChilren:Boolean,
            _partsLayout:PartsLayout,
            _background:IStretchBox;
        
        public function Element(
            layoutCalculator:LayoutCalculator,
            controllerClass:Class = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            _controller = controllerClass !== null ? controllerClass: Controller;
            
            _layoutCalculator = layoutCalculator || UNDEFINED_LAYOUT_CALCULATOR;
            
            _elementId = new ElementModelId(this);
            
            _elementWidth = _elementHeight = NaN;
            
            _partsLayout = new PartsLayout(this);
            
            _isCreatedChilren = false;
            
            if (backgroundBuilder)
                _background = backgroundBuilder.build(this);
        }
        
        public function initialize(storageId:String = null):void
        {
            if (storageId !== null)
            {
                _reader = controller.requestModelReader(storageId);
                _reader.addListener(this, StorageModelReader.LISTENER_PRIORITY_ELEMENT);
                _initializeRuntimeModel();
            }
        }
        
        protected function _initializeRuntimeModel():void
        {
        }
        
        public function reset():void
        {
            if (_reader)
            {
                _partsLayout.unbindStorageId();
                _reader.removeListener(this);
            }
        }
        
        public function destroy(withReference:Boolean = false):void
        {
            if (_reader)
            {
                _reader.removeListener(this);
                _reader = null;
            }
            
            if (_background)
            {
                _background.destroy();
                _background = null;
            }
            
            _partsLayout.destroy();
            _partsLayout = null;
            
            _elementId.destroy();
            _elementId = null;
            
            _layoutCalculator.destroy();
            _layoutCalculator = null;
            
            _controller = null;
            
            if (parent) removeFromParent(true);
        }
        
        public function addListener(type:String, listener:Function):void    { addEventListener(type, listener); }
        public function removeListener(type:String, listener:Function):void { removeEventListener(type, listener); }
        public function hasListener(type:String):void { hasEventListener(type); }
        
        public function enablePointerDeviceControl():void  {}
        public function disablePointerDeviceControl():void {}
        
        public function get elementWidth():Number          { return isNaN(_elementWidth)  ? width:  _elementWidth; }
        public function get elementHeight():Number         { return isNaN(_elementHeight) ? height: _elementHeight; }
        public function get controller():Controller        { return Controller.getInstance(_controller); }
        public function get storageId():String             { return _reader ? _reader.id: null; }
        
        public function get addTransition():Function       { return ElementTransition.FAST_ADD; }
        public function get mvoeTransition():Function      { return ElementTransition.LINER_MOVE; }
        public function get removeTransition():Function    { return ElementTransition.FAST_REMOVE; }
        public function get visibleTransition():Function   { return ElementTransition.FAST_VISIBLE; }
        public function get invisibleTransition():Function { return ElementTransition.FAST_INVISIBLE; }
        
        public function get parentElement():IElementContainer   { return parent as IElementContainer; }
        
        public function getPartsByName(name:String):*           { return getChildByName(name); }
        public function getPartsIndex(parts:*):int              { return getChildIndex(parts as DisplayObject); }
        public function addParts(parts:*):*                     { return addChild(parts as DisplayObject); }
        public function addPartsAt(parts:*, index:int):*        { return addChildAt(parts as DisplayObject, index); }
        public function removeParts(parts:*, dispose:Boolean = false):* { return removeChild(parts as DisplayObject, dispose); }
        
        //IStorageListener interface
        public function preview(plainDiff:Diff):void {}
        public function commit(plainDiff:Diff):void {}
        
        public function updateElementSize(elementWidth:Number, elementHeight:Number):void
        {
            if (_elementWidth != elementWidth || _elementHeight != elementHeight)
            {
                _partsLayout.refresh();
                
                _refreshBackground();
                
                dispatchEventWith(ElementEvent.UPDATE_SIZE);
            }
        }
        
        public function initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            _elementWidth  = _layoutCalculator.width.calc(actualParentWidth);
            _elementHeight = _layoutCalculator.height.calc(actualParentHeight);
            
            _isCreatedChilren ?
                _partsLayout.refresh():
                _buildParts();
            
            _partsLayout.bindStorageId(storageId);
            
            _refreshBackground();
        }
        
        protected function _buildParts():void
        {
            //Log.info("Element call _buildParts elementSize =", _elementWidth, _elementHeight);
            var builder:IDisplayObjectBuilder;
            var child:IBox;
            var _class:Class = $.getClassByInstance(this);
            
            var displayObjectPartsList:Array = Application.partsBlulePrint.createPartsList(_class);
            for (var i:int, iLen:int = displayObjectPartsList.length; i < iLen; i++) 
            {
                builder = Application.partsBlulePrint.createBuilder(displayObjectPartsList[i]);
                child   = builder.build(displayObjectPartsList[i], _elementWidth, _elementHeight);
                addParts(child is Grid9 ? (child as Grid9).asset: child);
                
                _partsLayout.setCalculator(child, builder.requestLayoutCalculator());
            }
            
            var elementPartsList:Array = Application.elementBluePrint.createPartsList(_class);
            for (var j:int, jLen:int = elementPartsList.length; j < jLen; j++) 
            {
                builder = Application.elementBluePrint.createBuilder(elementPartsList[j]);
                child   = builder.build(elementPartsList[i], _elementWidth, _elementHeight);
                addParts(child);
                
                _partsLayout.setCalculator(child, builder.requestLayoutCalculator());
            }
            
            _isCreatedChilren = true;
        }
        
        protected function _refreshBackground():void
        {
            if (_background)
            {
                _background.width  = _elementWidth;
                _background.height = _elementHeight;
            }
        }
    }
}