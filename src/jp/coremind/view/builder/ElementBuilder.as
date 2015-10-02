package jp.coremind.view.builder
{
    import jp.coremind.storage.Storage;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.LayoutCalculator;
    import jp.coremind.view.layout.Size;

    public class ElementBuilder implements IDisplayObjectBuilder
    {
        private static const TAG:String = "[ElementBuilder]";
        Log.addCustomTag(TAG);
        
        protected var
            _storageId:String,
            _elementClass:Class,
            _layoutCalculator:LayoutCalculator,
            _backgroundBuilder:IBackgroundBuilder;
        
        public function ElementBuilder(
            elementClass:Class,
            width:Size = null,
            height:Size = null,
            horizontalAlign:Align = null,
            verticalAlign:Align = null,
            storageId:String = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            _elementClass      = elementClass;
            _layoutCalculator  = new LayoutCalculator(width, height, horizontalAlign, verticalAlign);
            _storageId         = storageId || Storage.UNDEFINED_STORAGE_ID;
            _backgroundBuilder = backgroundBuilder;
        }
        
        public function overrideStorageId(storageId:String):ElementBuilder
        {
            _storageId = storageId;
            return this;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            Log.custom(TAG, "build", name);
            
            var element:IElement = new _elementClass(_layoutCalculator, _backgroundBuilder);
            element.name = name;
            element.initialize(actualParentWidth, actualParentHeight, _storageId);
            
            return element;
        }
        
        public function buildForListElement():IElement
        {
            Log.custom(TAG, "build for ListElement", _elementClass);
            return new _elementClass(null, _backgroundBuilder);;
        }
        
        public function get elementClass():Class
        {
            return _elementClass;
        }
        
        public function requestLayoutCalculator():LayoutCalculator
        {
            return _layoutCalculator;
        }
    }
}