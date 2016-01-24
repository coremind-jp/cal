package jp.coremind.view.builder
{
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.core.Application;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.builder.parts.BackgroundBuilder;

    public class ViewBuilder
    {
        private var
            _class:Class,
            _elementIdList:Array,
            _backgroundBuilder:BackgroundBuilder;
            
        public function ViewBuilder(elementIdList:Array, viewClass:Class = null)
        {
            _class = viewClass;
            _elementIdList = elementIdList;
        }
        
        public function build(name:String, commonView:Class):IView
        {
            var w:int = Application.configure.appViewPort.width;
            var h:int = Application.configure.appViewPort.height;
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            var result:IView = _class ? new _class(): new commonView();
            
            result.name = name;
            
            if (_backgroundBuilder)
            {
                var background:IStretchBox = _backgroundBuilder.build(result);
                background.width = w;
                background.height = h;
            }
            
            for (var i:int = 0; i < _elementIdList.length; i++) 
            {
                var elementId:String = _elementIdList[i];
                result.addDisplay(bluePrint.createBuilder(elementId).build(elementId, w, h) as IDisplayObject);
            }
            
            return result;
        }
        
        public function background(backgroundBuilder:BackgroundBuilder):ViewBuilder
        {
            _backgroundBuilder = backgroundBuilder;
            return this;
        }
    }
}