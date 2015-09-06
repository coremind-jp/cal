package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.component.ListContainer;
    import jp.coremind.view.implement.starling.component.ScrollContainer;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.ILayout;
    import jp.coremind.view.layout.Size;
    
    import starling.display.DisplayObject;
    
    public class ContainerElementBuilder extends ElementBuilder
    {
        protected var
            _layout:ILayout,
            _scrollOption:Vector.<ScrollOption>;
        
        public function ContainerElementBuilder(
            layout:ILayout,
            controllerClass:Class,
            width:Size,
            height:Size,
            horizontalAlign:Align,
            verticalAlign:Align,
            scrollOption:Vector.<ScrollOption> = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(ListContainer, controllerClass, width, height, horizontalAlign, verticalAlign, backgroundBuilder);
            
            _layout = layout;
            _scrollOption = scrollOption;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):DisplayObject
        {
            Log.info("build ContainerElement", _elementClass);
            
            var element:IElement = new _elementClass(_layout, _layoutCalculator, _controllerClass, null);
            var storageId:String;
            
            element.name = name;
            
            storageId = element.controller.initializeStorageModel(element.name);
            storageId === null ?
                Log.error("undefined StorageConfigure. instance '"+element.name+"'"):
                element.initialize(storageId);
            
            if (_scrollOption)
            {
                var scrollContainer:ScrollContainer = new ScrollContainer(_layoutCalculator, null, _backgroundBuilder);
                
                scrollContainer.wrap(element);
                scrollContainer.initializeElementSize(actualParentWidth, actualParentHeight);
                scrollContainer.x = _layoutCalculator.horizontalAlign.calc(actualParentWidth, element.elementWidth);
                scrollContainer.y = _layoutCalculator.verticalAlign.calc(actualParentHeight, element.elementHeight);
                
                for (var i:int; i < _scrollOption.length; i++)
                    _scrollOption[i].build(scrollContainer);
                
                element = scrollContainer;
            }
            else
            {
                element.initializeElementSize(actualParentWidth, actualParentHeight);
                element.x = _layoutCalculator.horizontalAlign.calc(actualParentWidth, element.elementWidth);
                element.y = _layoutCalculator.verticalAlign.calc(actualParentHeight, element.elementHeight);
            }
            
            return element as DisplayObject;
        }
    }
}