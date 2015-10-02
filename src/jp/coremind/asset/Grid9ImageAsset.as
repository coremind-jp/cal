package jp.coremind.asset
{
    import jp.coremind.view.implement.starling.buildin.Image;
    
    import starling.textures.Texture;
    import jp.coremind.asset.painter.CirclePainter;
    import jp.coremind.asset.painter.ColorPainter;

    public class Grid9ImageAsset extends GridAsset
    {
        public static function createRoundRect(
            assetId:String,
            color:uint,
            radius:int = 5,
            topLeft:Boolean = true,
            bottomLeft:Boolean = true,
            bottomRight:Boolean = true,
            topRight:Boolean = true):Grid9ImageAsset
        {
            var picker:TexturePicker = Asset.texture(assetId);
            
            return new Grid9ImageAsset().initialize(
                topLeft ?
                    picker.getPaintImage(CirclePainter, color, CirclePainter.QUARTER_TOP_LEFT, radius, radius):
                    picker.getPaintImage( ColorPainter, color, null, radius, radius),
                    
                picker.getPaintImage(ColorPainter, color, null, 1, radius),
                
                topRight ?
                    picker.getPaintImage(CirclePainter, color, CirclePainter.QUARTER_TOP_RIGHT, radius, radius):
                    picker.getPaintImage( ColorPainter, color, null, radius, radius),
                    
                picker.getPaintImage(ColorPainter, color, null, radius, 1),
                picker.getPaintImage(ColorPainter, color, null, radius, radius),
                picker.getPaintImage(ColorPainter, color, null, radius, 1),
                
                bottomLeft ?
                    picker.getPaintImage(CirclePainter, color, CirclePainter.QUARTER_BOTTOM_LEFT, radius, radius):
                    picker.getPaintImage( ColorPainter, color, null, radius, radius),
                    
                picker.getPaintImage(ColorPainter, color, null, 1, radius),
                
                bottomRight ?
                    picker.getPaintImage(CirclePainter, color, CirclePainter.QUARTER_BOTTOM_RIGHT, radius, radius):
                    picker.getPaintImage( ColorPainter, color, null, radius, radius));
        }
        
        public static function updateRoundRect(
            source:Grid9ImageAsset,
            assetId:String,
            color:uint,
            radius:int = 5,
            topLeft:Boolean = true,
            bottomLeft:Boolean = true,
            bottomRight:Boolean = true,
            topRight:Boolean = true):Grid9ImageAsset
        {
            var picker:TexturePicker = Asset.texture(assetId);
            var stretchParts:Texture = picker.getPaintTexture(ColorPainter, color);
            
            source.update(
                topLeft     ? picker.getPaintTexture(CirclePainter, color,     CirclePainter.QUARTER_TOP_LEFT): stretchParts,
                stretchParts,
                topRight    ? picker.getPaintTexture(CirclePainter, color,    CirclePainter.QUARTER_TOP_RIGHT): stretchParts,
                stretchParts, stretchParts, stretchParts,
                bottomLeft  ? picker.getPaintTexture(CirclePainter, color,  CirclePainter.QUARTER_BOTTOM_LEFT): stretchParts,
                stretchParts,
                bottomRight ? picker.getPaintTexture(CirclePainter, color, CirclePainter.QUARTER_BOTTOM_RIGHT): stretchParts);
            
            return source;
        }
        
        public function clone():GridAsset
        {
            if (numChildren == 9)
            {
                var topLeft:Image     = image(0);
                var top:Image         = image(1);
                var topRight:Image    = image(2);
                var left:Image        = image(3);
                var body:Image        = image(4);
                var right:Image       = image(5);
                var bottomLeft:Image  = image(6);
                var bottom:Image      = image(7);
                var bottomRight:Image = image(8);
                
                var result:GridAsset = new Grid9ImageAsset().initializeForTexture(
                    topLeft.texture,    top.texture,    topRight.texture,
                    left.texture,       body.texture,   right.texture,
                    bottomLeft.texture, bottom.texture, bottomRight.texture
                );
                
                _copyProperty(topLeft,      result.image(0));
                _copyProperty(top,          result.image(1));
                _copyProperty(topRight,     result.image(2));
                _copyProperty(left,         result.image(3));
                _copyProperty(body,         result.image(4));
                _copyProperty(right,        result.image(5));
                _copyProperty(bottomLeft,   result.image(6));
                _copyProperty(bottom,       result.image(7));
                _copyProperty(bottomRight,  result.image(8));
                
                return result;
            }
            else
                return new Grid9ImageAsset();
        }
        
        public function initialize(
            topLeft:Image,    top:Image,    topRight:Image,
            left:Image,       body:Image,   right:Image,
            bottomLeft:Image, bottom:Image, bottomRight:Image):Grid9ImageAsset
        {
            removeChildren(0, -1, true);
            
            addChild(topLeft);
            addChild(top);
            addChild(topRight);
            addChild(left);
            addChild(body);
            addChild(right);
            addChild(bottomLeft);
            addChild(bottom);
            addChild(bottomRight);
            
            return this;
        }
        
        public function initializeForTexture(
            topLeft:Texture,    top:Texture,    topRight:Texture,
            left:Texture,       body:Texture,   right:Texture,
            bottomLeft:Texture, bottom:Texture, bottomRight:Texture):Grid9ImageAsset
        {
            removeChildren(0, -1, true);
            
            addChild(new Image(topLeft));
            addChild(new Image(top));
            addChild(new Image(topRight));
            addChild(new Image(left));
            addChild(new Image(body));
            addChild(new Image(right));
            addChild(new Image(bottomLeft));
            addChild(new Image(bottom));
            addChild(new Image(bottomRight));
            
            return this;
        }
        
        public function update(
            topLeft:Texture = null,    top:Texture = null,    topRight:Texture = null,
            left:Texture = null,       body:Texture = null,   right:Texture = null,
            bottomLeft:Texture = null, bottom:Texture = null, bottomRight:Texture = null):void
        {
            if (numChildren == 9)
            {
                if (topLeft)        image(0).texture = topLeft;
                if (top)            image(1).texture = top;
                if (topRight)       image(2).texture = topRight;
                if (left)           image(3).texture = left;
                if (body)           image(4).texture = body;
                if (right)          image(5).texture = right;
                if (bottomLeft)     image(6).texture = bottomLeft;
                if (bottom)         image(7).texture = bottom;
                if (bottomRight)    image(8).texture = bottomRight;
            }
        }
    }
}