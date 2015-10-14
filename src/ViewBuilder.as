package
{
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.core.Application;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IView;

    public class ViewBuilder
    {
        private var
            _class:Class,
            _controller:Class,
            _elementIdList:Array;
            
        public function ViewBuilder(controllerClass:Class, elementIdList:Array, viewClass:Class = null)
        {
            _class = viewClass;
            _controller = controllerClass;
            _elementIdList = elementIdList;
        }
        
        public function build(name:String, commonView:Class):IView
        {
            var w:int = Application.configure.appViewPort.width;
            var h:int = Application.configure.appViewPort.height;
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            var result:IView = _class ?
                new _class(_controller):
                new commonView(_controller);
            
            result.name = name;
            for (var i:int = 0; i < _elementIdList.length; i++) 
            {
                var elementId:String = _elementIdList[i];
                result.addDisplay(bluePrint.createBuilder(elementId).build(elementId, w, h) as IDisplayObject);
            }
            
            return result;
        }
    }
}