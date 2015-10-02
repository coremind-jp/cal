package jp.coremind.view.builder
{
    import jp.coremind.asset.Grid9ImageAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.component.Grid9;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.Size;
    
    public class RoundRectBuilder extends BuildinDisplayObjectBuilder implements IDisplayObjectBuilder
    {
        private var
            _assetId:String,
            _color:uint,
            _radius:int,
            _topLeft:Boolean,
            _bottomLeft:Boolean,
            _bottomRight:Boolean,
            _topRight:Boolean;
        
        public function RoundRectBuilder(
            width:Size,
            height:Size,
            horizontalAlign:Align,
            verticalAlign:Align,
            assetId:String,
            color:uint,
            radius:int = 5,
            topLeft:Boolean = true,
            bottomLeft:Boolean = true,
            bottomRight:Boolean = true,
            topRight:Boolean = true)
        {
            super(width, height, horizontalAlign, verticalAlign);
            
            _assetId     = assetId;
            _color       = color;
            _radius      = radius;
            _topLeft     = topLeft;
            _bottomLeft  = bottomLeft;
            _bottomRight = bottomRight;
            _topRight    = topRight;
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var asset:Grid9ImageAsset = Grid9ImageAsset
                .createRoundRect(_assetId, _color, _radius, _topLeft, _bottomLeft, _bottomRight, _topRight);
            
            asset.name = name;
            
            var grid9:Grid9 = new Grid9().setAsset(asset);
            grid9.width  = _width.calc(actualParentWidth);
            grid9.height = _height.calc(actualParentHeight);
            
            Log.info("builded RoundRect", asset.width, asset.height);
            
            return grid9;
        }
    }
}