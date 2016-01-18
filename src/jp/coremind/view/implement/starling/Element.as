package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.event.ElementInfo;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.storage.IModelStorageListener;
    import jp.coremind.storage.ModelReader;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
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
            _reader:ModelReader,
            _layout:Layout,
            _info:ElementInfo,
            _elementWidth:Number,
            _elementHeight:Number,
            _storageInteractionId:String,
            _partsLayout:PartsLayout,
            _background:IStretchBox;
        
        /**
         * フレームワーク内で利用される基本表示オブジェクト.
         * ElementはUIからControllerへの橋渡しをしたり、Controllerのデータにアクセスして表示内容を切り替えるため
         * 表示オブジェクトであるので他の表示オブジェクトとは切り分けて考えられている。
         * 
         * 上記の理由から原則的にElementの中にElementを含めるのではなく
         * ビルドイン表示オブジェクト(TextField, Image, Quad, MovieClip等)のみとして想定してある。
         * 
         * ※要求仕様上Elementの中にElementを含める必要がある場合はContainerクラスやListContainerクラスを利用する。
         */
        public function Element(
            layoutCalculator:Layout,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            _layout = layoutCalculator || Layout.EQUAL_PARENT_TL;
            
            _elementWidth = _elementHeight = NaN;
            
            _partsLayout = new PartsLayout(this);
            
            if (backgroundBuilder) _background = backgroundBuilder.build(this);
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            Log.custom(TAG, "destroy", this, _info);
            _background = null;
            
            _partsLayout.destroy();
            
            _layout = null;
            
            if (_reader)
            {
                _reader.removeListener(this);
                _reader = null;
            }
            
            _info = null;
            
            super.destroy(withReference);
        }
        
        public function reset():void
        {
            if (_reader)
            {
                _partsLayout.reset();
                _reader.removeListener(this);
            }
            
            if (parent) removeFromParent();
        }
        
        public function get elementInfo():ElementInfo   { return _info; }
        public function get elementWidth():Number       { return isNaN(_elementWidth)  ? width:  _elementWidth; }
        public function get elementHeight():Number      { return isNaN(_elementHeight) ? height: _elementHeight; }
        
        //IListener interface
        public function addListener(type:String, listener:Function):void    { addEventListener(type, listener); }
        public function removeListener(type:String, listener:Function):void { removeEventListener(type, listener); }
        public function hasListener(type:String):void { hasEventListener(type); }
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
        
        //IStorageListener interface
        public function preview(plainDiff:Diff):void {}
        public function commit(plainDiff:Diff):void
        {
            _applyStorageInteraction(plainDiff.createUpdatedKeyList());
        }
        
        private function _applyStorageInteraction(updatedKeyList:Array):void
        {
            if (_storageInteractionId)
            {
                var si:StorageInteraction = Application.configure.interaction.getStorageInteraction(_storageInteractionId);
                if (si) si.apply(this, updatedKeyList);
            }
        }
        
        public function initialize(actualParentWidth:int, actualParentHeight:int, storageId:String = null, storageInteractionId:String = null, runInteractionOnCreated:Boolean = false):void
        {
            _info = new ElementInfo(storageId);
            _storageInteractionId = storageInteractionId;
            _initializeElementSize(actualParentWidth, actualParentHeight);
            
            var onAddedToStage:Function = function(e:Event):void
            {
                if (e) removeListener(Event.ADDED_TO_STAGE, arguments.callee);
                
                changeIdSuffix(name);
                
                _onLoadElementInfo();
                
                if (runInteractionOnCreated)
                    _applyStorageInteraction(_reader.createModelKeyList());
                
                ready();
            }
            
            stage ? onAddedToStage(): addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        protected function _initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            _elementWidth  = _layout.width.calc(actualParentWidth);
            _elementHeight = _layout.height.calc(actualParentHeight);
            
            x = _layout.horizontalAlign.calc(actualParentWidth, _elementWidth);
            y = _layout.verticalAlign.calc(actualParentHeight, _elementHeight);
            /*
            Log.custom(TAG,
                "actualSize:", actualParentWidth, actualParentHeight,
                "elementSize:", _elementWidth, _elementHeight,
                "position:", x, y);
            */
            if (!_partsLayout.isBuildedParts())
                _partsLayout.buildParts();
            
            _refreshLayout(_elementWidth, _elementHeight);
        }
        
        public function changeIdSuffix(idSuffix:String):void
        {
            name = idSuffix;
            
            var elementId:String = idSuffix;
            var ownerLayerId:String = "unknown";
            var ownerViewId:String  = "unknown";
            var p:ICalSprite = parent as ICalSprite;
            
            while (p)
            {
                if (p is IView)
                {
                    ownerViewId  = p.name;
                    ownerLayerId = p.parentDisplay ? p.parentDisplay.name: null;
                    break;
                }
                else
                {
                    //ContainerWrapperは暗黙レイヤーなのでパスとして含まない
                    if (!(p is ContainerWrapper)) elementId = p.name + "." + elementId;
                    p = p.parentDisplay as ICalSprite;
                }
            }
            
            _info.initialize(ownerLayerId, ownerViewId, elementId, idSuffix);
        }
        
        protected function _onLoadElementInfo():void
        {
            _reader = _info.reader;
            _reader.addListener(this, ModelReader.LISTENER_PRIORITY_ELEMENT);
            //Log.custom(TAG, "onLoadStorageModel", _reader.id, _reader.read());
            
            _initializeModules();
        }
        
        protected function _initializeModules():void
        {
            _info.modules;
        }
        
        public function updateElementSize(elementWidth:Number, elementHeight:Number):void
        {
            if (_elementWidth != elementWidth || _elementHeight != elementHeight)
            {
                _elementWidth  = elementWidth;
                _elementHeight = elementHeight;
                
                _refreshLayout(_elementWidth, _elementHeight);
                
                dispatchEventWith(ElementEvent.UPDATE_SIZE);
            }
        }
        
        protected function _refreshLayout(containerWidth:Number, containerHeight:Number):void
        {
            _partsLayout.refresh();
            
            if (_background)
            {
                _background.width  = containerWidth;
                _background.height = containerHeight;
            }
        }
        
        public function ready():void
        {
            dispatchEventWith(ElementEvent.READY);
            //Log.custom(TAG, "ready", "\nname:", name, "\nelementId:", elementId, "\nstorageId:", _reader.id, "\ncontroller:", controller);
        }
    }
}