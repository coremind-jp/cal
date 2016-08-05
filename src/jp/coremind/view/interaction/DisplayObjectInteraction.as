package jp.coremind.view.interaction
{
    import jp.coremind.asset.Grid3ImageAsset;
    import jp.coremind.asset.Grid9ImageAsset;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.component.Grid3X;
    import jp.coremind.view.abstract.component.Grid9;

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
            var child:* = parent.getDisplayByName(_name);
            var value:* = doInteraction(parent, child);
            
            if (child is Grid3ImageAsset && _targetPropertyName === "size")
                Grid3X.updateSize(child as Grid3ImageAsset, value);
            else
            if (child is Grid9ImageAsset)
            {
                switch (_targetPropertyName)
                {
                    case      "x": Grid9.updateX(     child as Grid9ImageAsset, value); break;
                    case      "Y": Grid9.updateY(     child as Grid9ImageAsset, value); break;
                    case  "width": Grid9.updateWidth( child as Grid9ImageAsset, value); break;
                    case "height": Grid9.updateHeight(child as Grid9ImageAsset, value); break;
                }
            }
            else (child || parent)[_targetPropertyName] = value;
        }
    }
}