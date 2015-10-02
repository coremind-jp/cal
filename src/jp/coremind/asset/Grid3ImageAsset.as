package jp.coremind.asset
{
    import jp.coremind.view.implement.starling.buildin.Image;
    import jp.coremind.view.layout.Direction;
    
    import starling.textures.Texture;
    import jp.coremind.asset.painter.CirclePainter;
    import jp.coremind.asset.painter.ColorPainter;

    public class Grid3ImageAsset extends GridAsset
    {
        public static function createProgressBar(direction:String, color:uint, thickness:int, assetId:String):Grid3ImageAsset
        {
            var picker:TexturePicker = Asset.texture(assetId);
            
            return direction === Direction.X ?
                new Grid3ImageAsset().initialize(
                    picker.getPaintImage(CirclePainter, color, CirclePainter.SEMI_LEFT, thickness >> 1, thickness),
                    picker.getPaintImage( ColorPainter, color, null, 1, thickness),
                    picker.getPaintImage(CirclePainter, color, CirclePainter.SEMI_RIGHT, thickness >> 1, thickness)):
                new Grid3ImageAsset().initialize(
                    picker.getPaintImage(CirclePainter, color, CirclePainter.SEMI_TOP, thickness, thickness >> 1),
                    picker.getPaintImage( ColorPainter, color, null, thickness, 1),
                    picker.getPaintImage(CirclePainter, color, CirclePainter.SEMI_BOTTOM, thickness, thickness >> 1));
        }
        
        public function clone():Grid3ImageAsset
        {
            if (numChildren == 3)
            {
                var head:Image = image(0);
                var body:Image = image(1);
                var tail:Image = image(2);
                
                var result:Grid3ImageAsset = new Grid3ImageAsset().initializeForTexture(
                    head.texture,
                    body.texture,
                    tail.texture);
                
                _copyProperty(head, result.image(0));
                _copyProperty(body, result.image(1));
                _copyProperty(tail, result.image(2));
                
                return result;
            }
            else
                return new Grid3ImageAsset();
        }
        
        public function initialize(head:Image, body:Image, tail:Image):Grid3ImageAsset
        {
            removeChildren(0, -1, true);
            
            addChild(head);
            addChild(body);
            addChild(tail);
            
            return this;
        }
        
        public function initializeForTexture(head:Texture, body:Texture, tail:Texture):Grid3ImageAsset
        {
            removeChildren(0, -1, true);
            
            addChild(new Image(head));
            addChild(new Image(body));
            addChild(new Image(tail));
            
            return this;
        }
        
        public function update(head:Texture = null, body:Texture = null, tail:Texture = null):void
        {
            if (numChildren == 3)
            {
                if (head) image(0).texture = head;
                if (body) image(1).texture = body;
                if (tail) image(2).texture = tail;
            }
        }
    }
}