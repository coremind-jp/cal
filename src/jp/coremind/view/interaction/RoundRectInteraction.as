package jp.coremind.view.interaction
{
    import jp.coremind.asset.Grid9ImageAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    
    public class RoundRectInteraction extends ElementInteraction
    {
        private var
            _assetId:String,
            _color:uint,
            _radius:int,
            _topLeft:Boolean,
            _bottomLeft:Boolean,
            _bottomRight:Boolean,
            _topRight:Boolean;
        
        public function RoundRectInteraction(
            applyTargetName:String,
            assetId:String,
            color:uint,
            radius:int = 5,
            topLeft:Boolean = true,
            bottomLeft:Boolean = true,
            bottomRight:Boolean = true,
            topRight:Boolean = true)
        {
            super(applyTargetName);
            
            _assetId     = assetId;
            _color       = color;
            _radius      = radius;
            _topLeft     = topLeft;
            _bottomLeft  = bottomLeft;
            _bottomRight = bottomRight;
            _topRight    = topRight;
            
            _injectionCode = function(previewValue:*, child:Grid9ImageAsset):void
            {
                Grid9ImageAsset.updateRoundRect(child, _assetId, _color, _radius, _topLeft, _bottomLeft, _bottomRight, _topRight);
            };
        }
        
        override public function apply(parent:IElement, previewData:*):void
        {
            var asset:Grid9ImageAsset = parent.getDisplayByName(_name) as Grid9ImageAsset;
            if (asset) doInteraction(parent, previewData, asset);
            else Log.warning("undefined Parts(RoundRectInteraction). name=", _name);
        }
    }
}