package jp.coremind.view.implement.starling
{
    import flash.geom.Rectangle;
    
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.Layout;
    
    public class ContainerWrapper extends Container
    {
        public static const NAME_SUFFIX:String = "Wrapper";
        protected var _wrappedContainer:IContainer;
        
        public function ContainerWrapper(layoutCalculator:Layout, backgroundBuilder:IBackgroundBuilder=null)
        {
            super(layoutCalculator, backgroundBuilder);
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            _wrappedContainer = null;
            
            super.destroy(withReference);
        }
        
        public function wrapContainer(container:IContainer):void
        {
            _wrappedContainer = container;
            name = _wrappedContainer.name + NAME_SUFFIX;
        }
        
        public function get wrappedContainer():IContainer
        {
            return _wrappedContainer;
        }
        
        public function enabledClipRect():void
        {
            clipRect = new Rectangle(0, 0, _maxWidth, _maxHeight);
        }
        
        public function disabledClipRect():void
        {
            clipRect = null;
        }
    }
}