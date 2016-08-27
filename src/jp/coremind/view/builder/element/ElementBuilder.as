package jp.coremind.view.builder.element
{
    import jp.coremind.storage.ModelStorage;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.DisplayObjectBuilder;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
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
            
            _storageId    = ModelStorage.UNDEFINED_STORAGE_ID;
            _elementClass = Element;
            _runInteractionOnCreated = true;
            
            touchable();
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
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            Log.custom(TAG, "build", name);
            
            return initializeElement(new _elementClass(layout, _backgroundBuilder), name, actualParentWidth, actualParentHeight);
        }
        
        public function initializeElement(element:IElement, name:String, actualParentWidth:int, actualParentHeight:int):IElement
        {
            Log.custom(TAG, "initialize", name);
            
            element.name = name;
            element.initialize(actualParentWidth, actualParentHeight, _storageId, _storageInteractionId, _runInteractionOnCreated);
            
            return element;
        }
    }
}