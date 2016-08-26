package jp.coremind.asset.painter
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    import jp.coremind.asset.Asset;
    import jp.coremind.asset.TextureMap;
    
    import starling.core.Starling;
    import starling.utils.Color;

    public class CirclePainter extends RuntimeTexturePainter
    {
        public static const CIRCLE:int = 0;
        
        public static const QUARTER_TOP_LEFT:int     = 1;
        public static const QUARTER_BOTTOM_LEFT:int  = 2;
        public static const QUARTER_BOTTOM_RIGHT:int = 3;
        public static const QUARTER_TOP_RIGHT:int    = 4;
        
        public static const SEMI_LEFT:int   = 5;
        public static const SEMI_RIGHT:int  = 6;
        public static const SEMI_TOP:int    = 7;
        public static const SEMI_BOTTOM:int = 8;
        
        public function CirclePainter(diameter:int)
        {
            super(diameter * Asset.textureScale, diameter * Asset.textureScale);
        }
        
        override protected function _drawTexture(distBitmapData:BitmapData, x:int, y:int, value:*):void
        {
            var diameter:int = _rect.width;
            var radius:int = diameter >> 1;
            var a:Number = starling.utils.Color.getAlpha(value) / 255;
            var rgb:uint = value << 8 >>> 8;
            var s:Shape = new Shape();
            
            s.graphics.beginFill(rgb, a);
            s.graphics.drawCircle(radius, radius, radius);
            s.graphics.endFill();
            
            distBitmapData.draw(s, new Matrix(1, 0, 0, 1, x, y), null, null, null, true);
        }
        
        override public function createSubTextureRect(value:*, clipOption:* = null):Rectangle
        {
            var map:TextureMap = _getTextureMap(value);
            if (!map) return new Rectangle();
            
            var diameter:int = _rect.width / Asset.textureScale;
            var result:Rectangle = new Rectangle(map.x, map.y, diameter, diameter);
            var radius:int = diameter >> 1;
            switch (clipOption)
            {
                case QUARTER_TOP_LEFT:
                    result.width = result.height = radius;
                    break;
                
                case QUARTER_BOTTOM_LEFT:
                    result.width = result.height = radius;
                    result.y += result.height;
                    break;
                
                case QUARTER_BOTTOM_RIGHT:
                    result.width = result.height = radius;
                    result.x += result.width;
                    result.y += result.height;
                    break;
                
                case QUARTER_TOP_RIGHT:
                    result.width = result.height = radius;
                    result.x += result.width;
                    break;
                
                case SEMI_LEFT:
                    result.width  = radius;
                    result.height = diameter;
                    break;
                
                case SEMI_RIGHT:
                    result.width  = radius;
                    result.height = diameter;
                    result.x += result.width;
                    break;
                
                case SEMI_TOP:
                    result.width  = diameter;
                    result.height = radius;
                    break;
                
                case SEMI_BOTTOM:
                    result.width  = diameter;
                    result.height = radius;
                    result.y += result.height;
                    break;
            }
            return result;
        }
    }
}