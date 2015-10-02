package jp.coremind.asset.painter
{
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    
    import jp.coremind.asset.TextureMap;

    public class ColorPainter extends RuntimeTexturePainter
    {
        public function ColorPainter()
        {
            super(3, 3);
        }
        
        override protected function _drawTexture(distBitmapData:BitmapData, x:int, y:int, value:*):void
        {
            distBitmapData.lock();
            for (var i:int = 0; i < _rect.width; i++) 
                for (var j:int = 0; j < _rect.height; j++) 
                    distBitmapData.setPixel32(x+i, y+j, value);
            distBitmapData.unlock();
        }
        
        override public function createSubTextureRect(value:*, option:* = null):Rectangle
        {
            var map:TextureMap = _getTextureMap(value);
            return new Rectangle(map.x + 1, map.y + 1, 1, 1);
        }
    }
}