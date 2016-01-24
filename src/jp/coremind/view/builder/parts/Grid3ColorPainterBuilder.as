package jp.coremind.view.builder.parts
{
    import jp.coremind.asset.Asset;
    import jp.coremind.asset.Grid3ImageAsset;
    import jp.coremind.asset.TexturePicker;
    import jp.coremind.asset.painter.CirclePainter;
    import jp.coremind.asset.painter.ColorPainter;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.component.Grid3X;
    import jp.coremind.view.abstract.component.Grid3Y;
    import jp.coremind.view.layout.Direction;
    import jp.coremind.view.layout.Layout;
    import jp.coremind.view.builder.DisplayObjectBuilder;
    
    public class Grid3ColorPainterBuilder extends DisplayObjectBuilder
    {
        private var
            _direction:String,
            _color:uint,
            _assetId:String;
        
        public function Grid3ColorPainterBuilder(layout:Layout, direction:String, color:uint, assetId:String)
        {
            super(layout);
            
            _direction = direction;
            _color     = color;
            _assetId   = assetId;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var picker:TexturePicker = Asset.texture(_assetId);
            var child:Grid3ImageAsset;
            var thickness:Number;
            
            if (_direction === Direction.X)
            {
                thickness = _layout.height.calc(actualParentHeight);
                
                child = new Grid3ImageAsset().initialize(
                    picker.getPaintImage(CirclePainter, _color, CirclePainter.SEMI_LEFT, thickness >> 1, thickness),
                    picker.getPaintImage( ColorPainter, _color, null, 1, thickness),
                    picker.getPaintImage(CirclePainter, _color, CirclePainter.SEMI_RIGHT, thickness >> 1, thickness));
                
                Grid3X.updateSize(child, _layout.width.calc(actualParentWidth));
            }
            else
            {
                thickness = _layout.width.calc(actualParentWidth);
                
                child = new Grid3ImageAsset().initialize(
                    picker.getPaintImage(CirclePainter, _color, CirclePainter.SEMI_TOP, thickness, thickness >> 1),
                    picker.getPaintImage( ColorPainter, _color, null, thickness, 1),
                    picker.getPaintImage(CirclePainter, _color, CirclePainter.SEMI_BOTTOM, thickness, thickness >> 1));
                
                Grid3Y.updateSize(child, _layout.height.calc(actualParentHeight));
            }
            
            child.name = name;
            child.x = _layout.horizontalAlign.calc(actualParentWidth, child.width);
            child.y = _layout.verticalAlign.calc(actualParentHeight, child.height);
            
            Log.info("builded Grid3ColorPainter");
            
            return child;
        }
    }
}