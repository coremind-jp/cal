package jp.coremind.view.layout
{
    public class Size
    {
        /** 親表示オブジェクトと同じサイズ */
        public static const PARENT_EQUAL:Size   = new Size(1.00, true);
        
        /** 親表示オブジェクトの半分のサイズ */
        public static const PARENT_HALF:Size    = new Size(0.50, true);
        
        /** 親表示オブジェクトの1/4のサイズ */
        public static const PARENT_QUARTER:Size = new Size(0.25, true);
        
        /** サイズ：0 */
        public static const ZERO:Size           = new Size(0, false);
        
        public static const EQUAL_TEXTURE:Size  = new Size(NaN, false);
        
        private var
            _size:Number,
            _dependParent:Boolean,
            _pixelOffset:int;
        
        public function Size(size:Number, depentdParent:Boolean = false)
        {
            _size = size;
            _dependParent = depentdParent;
            _pixelOffset = 0;
        }
        
        public function clone():Size
        {
            return new Size(_size, _dependParent);
        }
        
        public function calc(parentSize:Number):Number
        {
            return (_dependParent ? parentSize * _size: _size) + _pixelOffset;
        }
        
        public function pixelOffset(pixel:int):Size
        {
            _pixelOffset = pixel;
            return this;
        }
        
        /**
         * テクスチャーアトラスを利用している場合、サイズはXML内に予め含まれているが
         * それをわざわざ定義には含めるのが手間なので生成時に後から動的に入れるためのメソッド.
         */
        public function setAtlasTextureSize(size:Number):void
        {
            _size = size;
            _dependParent = false;
        }
    }
}