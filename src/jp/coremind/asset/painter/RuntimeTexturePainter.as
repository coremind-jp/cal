package jp.coremind.asset.painter
{
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.asset.TextureMap;
    import jp.coremind.utility.Log;
    
    import starling.core.Starling;

    public class RuntimeTexturePainter
    {
        public static var MAX_SCALE_FACTOR:int = 4;
        private static const _TEMP:Rectangle = new Rectangle();
        
        protected var
            _drawCount:int,
            _rect:Rectangle,
            _mapList:Dictionary;
            
        public function RuntimeTexturePainter(drawSizeWidth:int, drawSizeHeight:int)
        {
            _rect = new Rectangle(0, 0, drawSizeWidth * MAX_SCALE_FACTOR, drawSizeHeight * MAX_SCALE_FACTOR);
        }
        
        public function initialize(...values):RuntimeTexturePainter
        {
            _mapList = new Dictionary(false);
            for (var i:int = 0; i < values.length; i++) 
                _mapList[values[i]] = new TextureMap(0, 0);
            
            _drawCount = values.length;
            
            return this;
        }
        
        public function destroy():void
        {
            for (var p:* in _mapList) delete _mapList[p];
        }
        
        public function hasTextureMap(value:*):Boolean
        {
            return value in _mapList;
        }
        
        public function draw(sourceBitmapData:BitmapData, drawableArea:Rectangle):void
        {
            _copyRectValue(_TEMP, _rect);
            
            var globalX:int = _rect.x = drawableArea.x;
            var globalY:int = _rect.y = drawableArea.y;
            var localX:int = 0;
            var localY:int = 0;
            
            var maxDrawableX:int = drawableArea.width  / _rect.width;
            var maxDrawableY:int = drawableArea.height / _rect.height;
            if (_drawCount < maxDrawableX * maxDrawableY)
            {
                var dist:BitmapData = new BitmapData(drawableArea.width, drawableArea.height, true, 0);
                
                for (var p:* in _mapList) 
                {
                    if (drawableArea.width < localX + _rect.width)
                    {
                        localX  = 0;
                        localY += _rect.height;
                        
                        drawableArea.y      += _rect.height;
                        drawableArea.height -= _rect.height;
                    }
                    
                    var map:TextureMap = _mapList[p];
                    map.x = (globalX + localX) / Starling.contentScaleFactor;
                    map.y = (globalY + localY) / Starling.contentScaleFactor;
                    
                    _drawTexture(dist, localX, localY, p);
                    localX += _rect.width;
                }
                
                sourceBitmapData.copyPixels(
                    dist,
                    new Rectangle(0, 0, dist.width, dist.height),
                    new Point(globalX, globalY));
                dist.dispose();
                
                drawableArea.y      += _rect.height;
                drawableArea.height -= _rect.height;
            }
            else Log.error("RuntimeTextureDrawer.draw failed.", this, "max drawable num", maxDrawableX * maxDrawableY, "defined drawCount", _drawCount);
            
            _copyRectValue(_rect, _TEMP);
        }
        
        private function _copyRectValue(toRect:Rectangle, from:Rectangle):void
        {
            toRect.setTo(from.x, from.y, from.width, from.height);
        }
        
        protected function _drawTexture(distBitmapData:BitmapData, x:int, y:int, value:*):void
        {
            
        }
        
        protected function _getTextureMap(value:*):TextureMap
        {
            if (value in _mapList) return _mapList[value];
            else
            {
                Log.warning("failed createClipRect. undefined key '", value, "'");
                return null;
            }
        }
        
        public function createSubTextureRect(value:*, option:* = null):Rectangle
        {
            return new Rectangle();
        }
    }
}