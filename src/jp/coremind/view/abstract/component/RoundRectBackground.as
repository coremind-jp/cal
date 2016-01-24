package jp.coremind.view.abstract.component
{
    import jp.coremind.asset.Grid9ImageAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IStretchBox;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;

    public class RoundRectBackground implements IBackgroundBuilder
    {
        private static const NAME:String = "RectangleBackground";
        
        private var
            _assetId:String,
            _color:uint,
            _radius:int,
            _topLeft:Boolean,
            _bottomLeft:Boolean,
            _bottomRight:Boolean,
            _topRight:Boolean;
        
        public function RoundRectBackground(
            assetId:String,
            color:uint,
            radius:int = 0,
            topLeft:Boolean = true,
            bottomLeft:Boolean = true,
            bottomRight:Boolean = true,
            topRight:Boolean = true)
        {
            _assetId     = assetId;
            _color       = color;
            _radius      = radius;
            _topLeft     = topLeft;
            _bottomLeft  = bottomLeft;
            _bottomRight = bottomRight;
            _topRight    = topRight;
        }
        
        public function build(parent:ICalSprite):IStretchBox
        {
            var asset:Grid9ImageAsset = Grid9ImageAsset
                .createRoundRect(_assetId, _color, _radius, _topLeft, _bottomLeft, _bottomRight, _topRight);
            
            asset.name = NAME;
            parent.addDisplay(asset);
            Log.info("Static rectangle backgroudn builded")
            
            return new Grid9().setAsset(asset);
        }
    }
}