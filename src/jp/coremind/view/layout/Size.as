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
        
        private var
            _size:Number,
            _dependParent:Boolean;
        
        public function Size(size:Number, depentdParent:Boolean = false)
        {
            _size = size;
            _dependParent = depentdParent;
        }
        
        public function calc(parentSize:Number):Number
        {
            return _dependParent ? parentSize * _size: _size;
        }
    }
}