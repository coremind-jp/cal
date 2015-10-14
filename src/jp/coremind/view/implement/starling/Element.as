package jp.coremind.view.implement.starling
{
    import jp.coremind.control.Controller;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.model.ElementModel;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.storage.IStorageListener;
    import jp.coremind.storage.Storage;
    import jp.coremind.storage.StorageModelReader;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.Layout;
    import jp.coremind.view.layout.PartsLayout;
    
    import starling.events.Event;
    
    public class Element extends CalSprite implements IElement, IRecycle, IStorageListener
    {
        public static const TAG:String = "[Element]";
        Log.addCustomTag(TAG);
        
        protected var
            _reader:StorageModelReader,
            _layout:Layout,
            _elementWidth:Number,
            _elementHeight:Number,
            _elementId:String,
            _elementModel:ElementModel,
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
            Log.custom(TAG, "destroy", this, "storageId:", _reader ? _reader.id: null, "elementId:", _elementId);
            
            if (_background)
                _background = null;
            
            _partsLayout.destroy();
            
            _layout = null;
            
            if (_reader)
            {
                //StorageIdに紐づいていないElement（_readerIdがStorage.UNDEFINED_STORAGE_ID）の
                //ElementModelはView切り替え時でも破棄されないため、明示的に破棄する必要がある。
                controller.deleteElementModel(_elementId);
                
                _reader.removeListener(this);
                _reader = null;
            }
            
            _elementModel = null;
            
            super.destroy(withReference);
        }
        
        public function reset():void
        {
            if (_reader)
            {
                _partsLayout.reset();
                _reader.removeListener(this);
            }
        }
        
        public function get reader():StorageModelReader { return _reader; }
        public function get elementWidth():Number       { return isNaN(_elementWidth)  ? width:  _elementWidth; }
        public function get elementHeight():Number      { return isNaN(_elementHeight) ? height: _elementHeight; }
        public function get elementId():String          { return _elementId; }
        public function get elementModel():ElementModel { return _elementModel; }
        public function get controller():Controller
        {
            var parent:ICalSprite = this.parent as ICalSprite;
            
            while (parent)
                if (parent is IView) return (parent as IView).controller;
                else parent = parent.parentDisplay as ICalSprite;
            
            return Controller.getInstance();
        }
        
        public function get storageId():String      { return _reader ? _reader.id: null; }
        
        //IListener interface
        public function addListener(type:String, listener:Function):void    { addEventListener(type, listener); }
        public function removeListener(type:String, listener:Function):void { removeEventListener(type, listener); }
        public function hasListener(type:String):void { hasEventListener(type); }
        
        //IStorageListener interface
        public function preview(plainDiff:Diff):void {}
        public function commit(plainDiff:Diff):void {}
        
        public function initialize(actualParentWidth:int, actualParentHeight:int, storageId:String = null):void
        {
            _initializeElementSize(actualParentWidth, actualParentHeight);
            
            addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
            {
                removeListener(Event.ADDED_TO_STAGE, arguments.callee);
                
                _createElementId();
                
                _onLoadStorageReader(storageId);
                
                ready();
            });
        }
        
        protected function _initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            _elementWidth  = _layout.width.calc(actualParentWidth);
            _elementHeight = _layout.height.calc(actualParentHeight);
            
            x = _layout.horizontalAlign.calc(actualParentWidth, _elementWidth);
            y = _layout.verticalAlign.calc(actualParentHeight, _elementHeight);
            
            Log.custom(TAG,
                "actualSize:", actualParentWidth, actualParentHeight,
                "elementSize:", _elementWidth, _elementHeight,
                "position:", x, y);
            
            if (!_partsLayout.isBuildedParts())
                _partsLayout.buildParts();
            
            _refreshLayout(_elementWidth, _elementHeight);
        }
        
        private function _createElementId():void
        {
            _elementId = name;
            
            var p:ICalSprite = parent as ICalSprite;
            while (p)
            {
                if (p is IView) break;
                else
                {
                    _elementId = p.name + "." + _elementId;
                    p = p.parentDisplay as ICalSprite;
                }
            }
        }
        
        protected function _onLoadStorageReader(id:String):void
        {
            Log.custom(TAG, "onLoadStorageId", id);
            if (id)
            {
                _reader = controller.requestModelReader(id);
                _reader.addListener(this, StorageModelReader.LISTENER_PRIORITY_ELEMENT);
            }
            else
            {
                Log.info("undefined storageId", this, name);
                _reader = controller.requestModelReader(Storage.UNDEFINED_STORAGE_ID);
            }
            
            _initializeElementModel();
        }
        
        protected function _initializeElementModel():void
        {
            _elementModel = controller.requestModelElementModel(_reader.id, _elementId);
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
            //Log.custom(TAG, "ready", "\nname:", name, "\nelementId:", elementId, "\nstorageId:", _reader.id, "\ncontroller:", controller);
        }
    }
}