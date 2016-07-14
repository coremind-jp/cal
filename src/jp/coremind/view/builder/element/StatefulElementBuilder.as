package jp.coremind.view.builder.element
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
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
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            Log.custom(TAG, "build", name, _interactionId);
            
            var element:StatefulElement = new _elementClass(layout, _backgroundBuilder);
            element.name = name;
            element.interactionId = _interactionId;
            element.initialize(actualParentWidth, actualParentHeight, _storageId, _storageInteractionId, _runInteractionOnCreated);
            
            return element;
        }
        
        override public function buildForListElement():IElement
        {
            Log.custom(TAG, "build for ListElement", _elementClass);
            
            var element:StatefulElement = new _elementClass(null, _backgroundBuilder);
            element.interactionId = _interactionId;
            
            return element;
        }
    }
}