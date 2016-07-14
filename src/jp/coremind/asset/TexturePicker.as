package jp.coremind.asset
{
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.asset.painter.RuntimeTexturePainter;
    import jp.coremind.utility.Log;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    import starling.core.Starling;
    import starling.text.BitmapFont;
    import starling.textures.SubTexture;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    public class TexturePicker
    {
        private static const TAG:String = "[TexturePicker]";
        Log.addCustomTag(TAG);
        
        private var
            _atlas:TextureAtlas,
            
            _cacheList:Dictionary,
            _cacheKeyList:Object,
            
            _painterList:Vector.<RuntimeTexturePainter>,
            _bitmapFontList:Object;
        
        public function TexturePicker()
        {
            _cacheList = new Dictionary(true);
            _cacheKeyList = {};
            
            _painterList = new <RuntimeTexturePainter>[];
            _bitmapFontList = {};
        }
        
        public function initialize(source:BitmapData, atlasXml:XML, paintableArea:Rectangle):void
        {
            for (var i:int = 0; i < _painterList.length; i++) 
                _painterList[i].draw(source, paintableArea);
            
            var sourceTexture:Texture = Texture.fromBitmapData(source, false, false, Starling.contentScaleFactor);
            
            if (atlasXml) _atlas = new TextureAtlas(sourceTexture, atlasXml);
            
            //Application.stage.addChild(new Bitmap(source));
        }
        
        public function destroy():void
        {
            Log.custom(TAG, "destroy");
            
            for (var texture:Texture in _cacheList)
            {
                texture.dispose();
                delete _cacheList[texture];
            }
            
            for (var p:* in _cacheKeyList)
                delete _cacheKeyList[p];
            
            for (var i:int = 0; i < _painterList.length; i++) 
                _painterList[i].destroy();
            _painterList.length = 0;
            
            for (p in _bitmapFontList)
            {
                (_bitmapFontList[p] as BitmapFont).dispose();
                delete _bitmapFontList[p];
            }
            
            if (_atlas)
            {
                _atlas.dispose();
                _atlas = null;
            }
        }
        
        public function addPainter(painter:RuntimeTexturePainter):TexturePicker
        {
            _painterList.push(painter);
            return this;
        }
        
        public function createBitmapFont(fontName:String, fontXml:XML):void
        {
            _bitmapFontList[fontName] = new BitmapFont(_atlas.texture, fontXml);
        }
        
        public function getBitmapFont(fontName:String):BitmapFont
        {
            return _bitmapFontList[fontName];
        }
        
        public function getAtlasTexture(name:String):Texture
        {
            var texture:Texture = _atlas.getTexture(name);
            
            _addCacheTexture(name, texture);
            
            return texture;
        }
        
        public function getPaintTexture(painterClass:Class, paintValue:*, clipOption:* = null):Texture
        {
            var cacheKey:String = String(painterClass) + String(paintValue) + String(clipOption);
            var cache:Texture = _getCacheTexture(cacheKey);
            
            if (cache) return cache;
            else
            {
                var painter:RuntimeTexturePainter = _getPainter(painterClass);
                if (painter)
                {
                    var texture:Texture = new SubTexture(
                        _atlas.texture,
                        painter.createSubTextureRect(paintValue, clipOption));
                    
                    _addCacheTexture(cacheKey, texture);
                    
                    return texture;
                }
            }
            
            Log.error("undefined paintTexture. paintValue:", paintValue);
            return null;
        }
        
        private function _getCacheTexture(cacheKey:String):Texture
        {
            if (cacheKey in _cacheKeyList)
                for (var p:Texture in _cacheList) 
                    if (_cacheList[p] === cacheKey)
                        return p;
            return null;
        }
        
        private function _getPainter(painterClass:Class):RuntimeTexturePainter
        {
            for (var i:int = 0; i < _painterList.length; i++) 
                if (_painterList[i] is painterClass)
                    return _painterList[i];
            return null;
        }
        
        private function _addCacheTexture(cacheKey:String, texture:Texture):void
        {
            if (!(cacheKey in _cacheKeyList))
            {
                _cacheKeyList[cacheKey] = null;
                _cacheList[texture] = cacheKey;
            }
        }
        
        public function getAtlasImage(name:String, width:Number = NaN, height:Number = NaN):Image
        {
            return _wrapImage(getAtlasTexture(name), width, height);
        }
        
        public function getPaintImage(painterClass:Class, paintValue:*, clipOption:* = null, width:Number = NaN, height:Number = NaN):Image
        {
            return _wrapImage(getPaintTexture(painterClass, paintValue, clipOption), width, height);
        }
        
        private function _wrapImage(texture:Texture, width:Number = NaN, height:Number = NaN):Image
        {
            var image:Image = new Image(texture);
            
            if (!isNaN(width))  image.scaleX =  width /  image.width;
            if (!isNaN(height)) image.scaleY = height / image.height;
            
            return image;
        }
    }
}