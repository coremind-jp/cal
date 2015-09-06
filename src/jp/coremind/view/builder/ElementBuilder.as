package jp.coremind.view.builder
{
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.LayoutCalculator;
    import jp.coremind.view.layout.Size;
    
    import starling.display.DisplayObject;

    public class ElementBuilder implements IDisplayObjectBuilder
    {
        protected var
            _aliasStorageId:String,
            _elementClass:Class,
            _controllerClass:Class,
            _layoutCalculator:LayoutCalculator,
            _backgroundBuilder:IBackgroundBuilder;
        
        public function ElementBuilder(
            elementClass:Class,
            controllerClass:Class,
            width:Size = null,
            height:Size = null,
            horizontalAlign:Align = null,
            verticalAlign:Align = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            _aliasStorageId    = null;
            _elementClass      = elementClass;
            _controllerClass   = controllerClass;
            _layoutCalculator  = new LayoutCalculator(width, height, horizontalAlign, verticalAlign);
            _backgroundBuilder = backgroundBuilder;
        }
        
        public function aliasStorageId(storageId:String):ElementBuilder
        {
            _aliasStorageId = storageId;
            return this;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):DisplayObject
        {
            Log.info("ElementBuilder build", name);
            
            var element:IElement = new _elementClass(_layoutCalculator, _controllerClass, _backgroundBuilder);
            var storageId:String;
            
            element.name = name;
            
            storageId = element.controller.initializeStorageModel(_aliasStorageId !== null ? _aliasStorageId: element.name);
            storageId === null ?
                Log.error("undefined StorageConfigure. instance '"+element.name+"'"):
                element.initialize(storageId);
            
            element.initializeElementSize(actualParentWidth, actualParentHeight);
            element.x = _layoutCalculator.horizontalAlign.calc(actualParentWidth, element.elementWidth);
            element.y = _layoutCalculator.verticalAlign.calc(actualParentHeight, element.elementHeight);
            
            return element as DisplayObject;
        }
        
        public function buildForListElement():IElement
        {
            Log.info("ElementBuilder build for ListElement", _elementClass);
            return new _elementClass(null, _controllerClass, _backgroundBuilder);
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