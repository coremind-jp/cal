package jp.coremind.view.builder
{
    import jp.coremind.storage.Storage;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.Element;
    import jp.coremind.view.layout.Layout;

    public class ElementBuilder extends DisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private static const TAG:String = "[ElementBuilder]";
        Log.addCustomTag(TAG);
        
        protected var
            _storageId:String,
            _storageInteractionId:String,
            _runInteractionOnCreated:Boolean,
            _elementClass:Class,
            _backgroundBuilder:IBackgroundBuilder;
        
        public function ElementBuilder(layout:Layout = null)
        {
            super(layout);
            
            _storageId    = Storage.UNDEFINED_STORAGE_ID;
            _elementClass = Element;
            _runInteractionOnCreated = false;
        }
        
        public function getElementClass():Class
        {
            return _elementClass;
        }
        
        public function elementClass(elementClass:Class):ElementBuilder
        {
            _elementClass = elementClass;
            return this;
        }
        
        public function background(backgroundBuilder:IBackgroundBuilder):ElementBuilder
        {
            _backgroundBuilder = backgroundBuilder;
            return this;
        }
        
        public function storageId(storageId:String):ElementBuilder
        {
            _storageId = storageId;
            return this;
        }
        
        public function storageInteraction(storageInteractionId:String, runInteractionOnCreated:Boolean = true):ElementBuilder
        {
            _storageInteractionId = storageInteractionId;
            _runInteractionOnCreated = runInteractionOnCreated;
            return this;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            Log.custom(TAG, "build", name);
            
            var element:IElement = new _elementClass(layout, _backgroundBuilder);
            element.name = name;
            element.initialize(actualParentWidth, actualParentHeight, _storageId, _storageInteractionId, _runInteractionOnCreated);
            
            return element;
        }
        
        public function buildForListElement():IElement
        {
            Log.custom(TAG, "build for ListElement", _elementClass);
            return new _elementClass(null, _backgroundBuilder);
        }
    }
}