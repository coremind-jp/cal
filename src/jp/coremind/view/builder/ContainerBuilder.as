package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.implement.starling.component.ListContainer;
    import jp.coremind.view.implement.starling.component.ScrollContainer;
    import jp.coremind.view.layout.IListLayout;
    import jp.coremind.view.layout.Layout;
    
    public class ContainerBuilder extends ElementBuilder
    {
        protected var
            _listLayout:IListLayout,
            _scrollOption:Vector.<ScrollOption>;
        
        public function ContainerBuilder(storageId:String, listLayout:IListLayout, layout:Layout = null)
        {
            super(layout);
            
            this.storageId(storageId);
            _listLayout = listLayout;
        }

        public function scrollOption(scrollOption:Vector.<ScrollOption>):ContainerBuilder
        {
            _scrollOption = scrollOption;
            return this;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            Log.info("build ContainerElement", _elementClass);
            
            var container:IContainer = new ListContainer(_listLayout, _layout, null);
            
            container.name = name;
            
            if (_scrollOption)
            {
                var scrollContainer:ScrollContainer = new ScrollContainer(_layout, _backgroundBuilder);
                
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