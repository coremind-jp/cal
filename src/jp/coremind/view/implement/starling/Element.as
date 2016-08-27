package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.event.ElementInfo;
    import jp.coremind.storage.IModelStorageListener;
    import jp.coremind.storage.ModelStorage;
    import jp.coremind.storage.transaction.Diff;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.component.ListContainer;
    import jp.coremind.view.interaction.StorageInteraction;
    import jp.coremind.view.layout.Layout;
    import jp.coremind.view.layout.PartsLayout;
    
    import starling.events.Event;
    
    public class Element extends CalSprite implements IElement, IRecycle, IModelStorageListener
    {
        public static const TAG:String = "[Element]";
        Log.addCustomTag(TAG);
        
        private static const READY_EVENT:ElementEvent = new ElementEvent(ElementEvent.READY);
        
        protected var
            _layout:Layout,
            _info:ElementInfo,
            _elementWidth:Number,
            _elementHeight:Number,
            _storageInteractionId:String,
            _partsLayout:PartsLayout,
            _background:IStretchBox;
        
        /**
         */
        public function Element(
            layoutCalculator:Layout,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            _layout = layoutCalculator || Layout.EQUAL_PARENT_TL;
            
            _info = new ElementInfo();
            
            _elementWidth = _elementHeight = NaN;
            
            _partsLayout = new PartsLayout(this);
            
            if (backgroundBuilder) _background = backgroundBuilder.build(this);
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            Log.custom(TAG, "destroy", this, _info);
            
            _partsLayout.destroy();
            _info.reset(this);
            
            _background = null;
            _layout = null;
            
            super.destroy(withReference);
        }
        
        public function reset():void
        {
            Log.custom(TAG, "reset", name);
            
            _partsLayout.reset();
            _info.reset(this);
            
            if (parent) removeFromParent();
        }
        
        //IListener interface
        public function addListener(type:String, listener:Function):void    { addEventListener(type, listener); }
        public function removeListener(type:String, listener:Function):void { removeEventListener(type, listener); }
        public function hasListener(type:String):void { hasEventListener(type); }
        
        //IStorageListener interface
        public function commit(diff:Diff):void {}
        public function preview(diff:Diff):void
        {
            if (diff.hashInfo)
                _applyStorageInteraction(diff.hashInfo.edited);
        }
        
        //IElement interface
        public function get elementInfo():ElementInfo   { return _info; }
        public function get elementWidth():Number       { return isNaN(_elementWidth)  ? width:  _elementWidth; }
        public function get elementHeight():Number      { return isNaN(_elementHeight) ? height: _elementHeight; }
        public function clone():IElement
        {
            var listContainer:ListContainer = parent as ListContainer;
            if (listContainer) return listContainer.cloneListElement(_info);
            
            var builder:IDisplayObjectBuilder = Application.configure.elementBluePrint.createBuilder(name);
            var container:IContainer = parent as IContainer;
            if (container) return builder.build(name, container.maxWidth, container.maxHeight) as IElement;
            
            var element:IElement = parent as IElement;
            return element ?
                builder.build(name, container.maxWidth, container.maxHeight) as IElement:
                builder.build(name, parent.width, parent.height) as IElement;
        }
        
        public function initialize(actualParentWidth:int, actualParentHeight:int, storageId:String = ModelStorage.UNDEFINED_STORAGE_ID, storageInteractionId:String = null, runInteractionOnCreated:Boolean = false):void
        {
            _initializeElementSize(actualParentWidth, actualParentHeight);
            _initializeChildren();
            
            _refreshBackground();
            
            _info.setReader(storageId, this);
            
            _storageInteractionId = storageInteractionId;
            
            var addedOnStage:Function = function(e:Event = null):void
            {
                if (e) removeListener(Event.ADDED_TO_STAGE, arguments.callee);
                
                _initializeModules();
                
                if (storageId != ModelStorage.UNDEFINED_STORAGE_ID
                &&  runInteractionOnCreated)
                {
                    _applyStorageInteraction(_info.reader.createKeyList());
                }
                
                ready();
            }
            
            stage ? addedOnStage(): addEventListener(Event.ADDED_TO_STAGE, addedOnStage);
        }
        
        protected function _initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            _elementWidth  = _layout.width.calc(actualParentWidth);
            _elementHeight = _layout.height.calc(actualParentHeight);
            
            x = _layout.horizontalAlign.calc(actualParentWidth, _elementWidth);
            y = _layout.verticalAlign.calc(actualParentHeight, _elementHeight);
        }
        
        protected function _initializeChildren():void
        {
            _partsLayout.isBuilded() ? _partsLayout.refresh(): _partsLayout.buildParts();
        }
        
        protected function _refreshBackground():void
        {
            if (!_background) return;
            
            _background.width  = _elementWidth;
            _background.height = _elementHeight;
        }
        
        protected function _initializeModules():void
        {
            _info.path.parse(this);
            _info.loadModules();
        }
        
        protected function _applyStorageInteraction(updatedKeyList:Vector.<String>):void
        {
            if (_storageInteractionId)
            {
                var si:StorageInteraction = Application.configure.interaction.getStorageInteraction(_storageInteractionId);
                if (si) si.apply(this, updatedKeyList);
            }
        }
        
        public function ready():void
        {
            dispatchEventWith(ElementEvent.READY);
        }
        
        public function changeIdSuffix(idSuffix:String):void
        {
            _info.changeIdSuffix(name = idSuffix, this);
        }
        
        public function updateElementSize(elementWidth:Number, elementHeight:Number):void
        {
            if (_elementWidth != elementWidth || _elementHeight != elementHeight)
            {
                _elementWidth  = elementWidth;
                _elementHeight = elementHeight;
                
                _refreshLayout();
                
                dispatchEventWith(ElementEvent.UPDATE_SIZE);
            }
        }
        
        protected function _refreshLayout():void
        {
            _refreshBackground();
            _partsLayout.refresh();
        }
    }
}