package jp.coremind.view.interaction
{
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IElement;

    public class DisplayObjectInteraction extends ElementInteraction
    {
        protected var _targetPropertyName:String;
        
        public function DisplayObjectInteraction(applyTargetName:String, targetPropertyName:String)
        {
            super(applyTargetName);
            
            _targetPropertyName = targetPropertyName;
        }
        
        override public function apply(parent:IElement):void
        {
            var  child:IDisplayObject = parent.getDisplayByName(_name) as IDisplayObject;
            var target:IDisplayObject = child || parent;
            
            target[_targetPropertyName] = doInteraction(parent, null);
        }
    }
}