package jp.coremind.view.builder.element
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.component.ListContainer;
    import jp.coremind.view.layout.IListLayout;
    import jp.coremind.view.layout.Layout;
    
    public class ListContainerBuilder extends ElementBuilder
    {
        protected var
            _listLayout:IListLayout;
        
        public function ListContainerBuilder(listLayout:IListLayout, layout:Layout = null)
        {
            super(layout || Layout.EQUAL_PARENT_TL);
            
            _elementClass = ListContainer;
            _listLayout = listLayout;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var container:ListContainer;
            
            Log.info("build ListContainer", _elementClass);
            
            container = new _elementClass(_listLayout, _layout, _backgroundBuilder);
            container.name = name;
            container.initialize(actualParentWidth, actualParentHeight, _storageId);
            
            return container;
        }
    }
}