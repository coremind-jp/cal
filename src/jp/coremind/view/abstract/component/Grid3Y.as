package jp.coremind.view.abstract.component
{
    import jp.coremind.asset.GridAsset;
    import jp.coremind.view.abstract.IStretchBar;
    import jp.coremind.view.layout.Direction;
    
    /**
     * Grid3クラスの可変長方向をY軸基準で実装したクラス.
     */
    public class Grid3Y extends Grid3 implements IStretchBar
    {
        private static const TEMP:Grid3Y = new Grid3Y();
        public static function updateSize(grid3:GridAsset, size:Number):void
        {
            TEMP.setAsset(grid3).size = size;
            TEMP.destroy();
        }
        
        public function Grid3Y(line:int = GridAsset.GRID3_LINE)
        {
            if (line === GridAsset.GRID3_LINE)
            {
                _headIndex = 0;
                _bodyIndex = 1;
                _tailIndex = 2;
            }
            else
            {
                _headIndex = 0 + line;
                _bodyIndex = 3 + line;
                _tailIndex = 6 + line;
            }
        }
        
        override public function setAsset(asset:GridAsset):Grid3
        {
            super.setAsset(asset);
            
            _headSize = _head.height;
            _tailSize = _tail.height;
            
            return this;
        }
        
        public function get direction():String { return Direction.Y; }
        
        override public function set size(value:Number):void
        {
            if (value < 0) value = 0;
            
            var offset:int   = _headSize + _tailSize;
            var bodySize:int = value < offset ? 0: (value - offset)|0;
            
            _body.y      = _headSize;
            _body.height = bodySize;
            
            _tail.y = _headSize + bodySize;
            _size   = _tail.y + _tailSize;
        }
        
        override public function get position():Number
        {
            return _asset.y;
        }
        
        override public function set position(value:Number):void
        {
            _asset.y = (value + .5)|0;
        }
    }
}