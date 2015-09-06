package jp.coremind.resource
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.Log;
    import jp.coremind.view.implement.starling.buildin.Image;
    import jp.coremind.view.parts.StretchImage;
    
    import starling.text.BitmapFont;
    import starling.textures.SubTexture;
    import starling.textures.Texture;

    public class EmbedResource
    {
        [Embed(source="../../../../libs/fonts/font.fnt", mimeType="application/octet-stream")]
        private static const FontXml:Class;
        
        [Embed(source = "../../../../libs/fonts/font.png")]
        private static const _COMMON_TEXTURE_CLASS:Class;
        private static var   _COMMON_TEXTURE:Texture;
        public  static const commonTextureSource:BitmapData = new _COMMON_TEXTURE_CLASS().bitmapData;
        
        private static const CIRCLE_DRAWING_POSITION:Rectangle = new Rectangle(0, 110);
        private static const CALC_RECT:Rectangle = new Rectangle();
        private static var ACTUAL_CIRCLE_SIZE:int = 20;
        public static function addCircleSource(color:int = 0xffffff):void
        {
            CIRCLE_DRAWING_POSITION.width  = ACTUAL_CIRCLE_SIZE;
            CIRCLE_DRAWING_POSITION.height = ACTUAL_CIRCLE_SIZE;
            var half:int = ACTUAL_CIRCLE_SIZE >> 1;
            
            var s:Shape = new Shape();
            s.graphics.beginFill(0xffffff, 1); 
            s.graphics.drawCircle(half, half, half);
            s.graphics.endFill();
            
            var bmpd:BitmapData = new BitmapData(ACTUAL_CIRCLE_SIZE, ACTUAL_CIRCLE_SIZE, true, 0);
            bmpd.draw(s);
            
            commonTextureSource.copyPixels(
                bmpd,
                new Rectangle(0, 0, ACTUAL_CIRCLE_SIZE, ACTUAL_CIRCLE_SIZE),
                new Point(CIRCLE_DRAWING_POSITION.x, CIRCLE_DRAWING_POSITION.y));
        }
        public static function createCircleImage(type:int, size:int):Image
        {
            CALC_RECT.setTo(CIRCLE_DRAWING_POSITION.x, CIRCLE_DRAWING_POSITION.y, CIRCLE_DRAWING_POSITION.width, CIRCLE_DRAWING_POSITION.height);
            
            var result:Image = createImage(CircleTexture.createClipRect(type, ACTUAL_CIRCLE_SIZE, CALC_RECT));
            result.scaleX = result.scaleY = size / ACTUAL_CIRCLE_SIZE;
            
            return result;
        }
        
        private static var   COLOR_CHART_LENGTH:int = 0;
        private static const COLOR_CHART_DRAWING_POSITION:Point = new Point(0, 150);
        private static const COLOR_CHART_LIST:Object = {};
        private static const COLOR_TEXTURE:Object = {};
        public static function createColorChart(...colorList):void
        {
            var color:uint, n:int, x:int, y:int;
            
            //forced push alpha sheet.
            colorList.push(0);
            
            for (var i:int = 0; i < colorList.length; i++) 
            {
                color = colorList[i];
                COLOR_CHART_LIST[color] = n = COLOR_CHART_LENGTH++;
                
                x = n % commonTextureSource.width * 3 + COLOR_CHART_DRAWING_POSITION.x;
                y = n / commonTextureSource.width * 3 + COLOR_CHART_DRAWING_POSITION.y;
                
                for (var j:int = 0; j < 3; j++) 
                    for (var k:int = 0; k < 3; k++) 
                        commonTextureSource.setPixel32(x+j, y+k, color);
            }
        }
        
        private static var _BITMAP_FONT:BitmapFont;
        public static function getBitmapFont(fontFace:String = null):BitmapFont { return _BITMAP_FONT; }
        
        public static function initialize():void
        {
            _COMMON_TEXTURE = Texture.fromBitmapData(commonTextureSource, true, false);
            _BITMAP_FONT = new BitmapFont(_COMMON_TEXTURE, XML(new FontXml()));
        }
        
        public static function requestColorTexture(color:uint):SubTexture
        {
            if (color in COLOR_TEXTURE)
                return COLOR_TEXTURE[color];
            else
            if (color in COLOR_CHART_LIST)
            {
                var n:int = COLOR_CHART_LIST[color];
                var x:int = n % commonTextureSource.width * 3 + COLOR_CHART_DRAWING_POSITION.x + 1;
                var y:int = n / commonTextureSource.width * 3 + COLOR_CHART_DRAWING_POSITION.y + 1;
                return COLOR_TEXTURE[color] = new SubTexture(_COMMON_TEXTURE, new Rectangle(x, y, 1, 1));
            }
            else
            {
                Log.error("undefined ColorTexure.", color.toString(16));
                return null;
            }
        }
        
        public static function createColorImage(color:int, w:Number = 1, h:Number = 1):Image
        {
            var img:Image = new Image(requestColorTexture(color));
            
            img.width  = w;
            img.height = h;
            
            return img;
        }
        
        public static function createColorStretchImage(color:int, w:Number = 1, h:Number = 1):StretchImage
        {
            var img:StretchImage = new StretchImage(requestColorTexture(color));
            
            img.width  = w;
            img.height = h;
            
            return img;
        }
        
        public static function createImage(rect:Rectangle):Image
        {
            var img:Image = new Image(new SubTexture(_COMMON_TEXTURE, rect));
            
            return img;
        }
    }
}