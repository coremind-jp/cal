package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.implement.starling.component.ListContainer;
    import jp.coremind.view.implement.starling.component.ScrollContainer;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.IElementLayout;
    import jp.coremind.view.layout.Size;
    
    public class ContainerBuilder extends ElementBuilder
    {
        protected var
            _layout:IElementLayout,
            _scrollOption:Vector.<ScrollOption>;
        
        public function ContainerBuilder(
            layout:IElementLayout,
            width:Size,
            height:Size,
            horizontalAlign:Align,
            verticalAlign:Align,
            storageId:String = null,
            scrollOption:Vector.<ScrollOption> = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(ListContainer, width, height, horizontalAlign, verticalAlign, storageId, backgroundBuilder);
            
            _layout = layout;
            _scrollOption = scrollOption;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            Log.info("build ContainerElement", _elementClass);
            
            var container:IContainer = new _elementClass(_layout, _layoutCalculator, null);
            
            container.name = name;
            
            if (_scrollOption)
            {
                var scrollContainer:ScrollContainer = new ScrollContainer(_layoutCalculator, _backgroundBuilder);
                
                scrollContainer.wrap(container);
                scrollContainer.initialize(actualParentWidth, actualParentHeight, _storageId);
                
                for (var i:int; i < _scrollOption.length; i++)
                    _scrollOption[i].build(scrollContainer);
                
                return scrollContainer;
            }
            else
            {
                container.initialize(actualParentWidth, actualParentHeight, _storageId);
                
                return container;
            }
        }
    }
}