package jp.coremind.view.builder.element
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.StatefulElement;
    import jp.coremind.view.layout.Layout;
    
    public class StatefulElementBuilder extends ElementBuilder
    {
        private static const TAG:String = "[StatefulElementBuilder]";
        Log.addCustomTag(TAG);
        
        protected var _interactionId:String;
        
        public function StatefulElementBuilder(interactionId:String, layout:Layout=null)
        {
            super(layout);
            
            _elementClass  = StatefulElement;
            _interactionId = interactionId;
        }
        
        override public function initializeElement(element:IElement, name:String, actualParentWidth:int, actualParentHeight:int):IElement
        {
            (element as StatefulElement).interactionId = _interactionId;
            
            return super.initializeElement(element, name, actualParentWidth, actualParentHeight);
        }
    }
}