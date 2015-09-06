package jp.coremind.view.abstract.component
{
    import jp.coremind.asset.GridAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IStretchBar;
    import jp.coremind.view.layout.Direction;
    
    /**
     * Grid3クラスの可変長方向をX軸基準で実装したクラス.
     */
    public class Grid3X extends Grid3 implements IStretchBar
    {
        public function Grid3X(line:int = GridAsset.GRID3_LINE)
        {
            if (line === GridAsset.GRID3_LINE)
            {
                _headIndex = 0;
                _bodyIndex = 1;
                _tailIndex = 2;
            }
            else
            {
                _headIndex = line * 3;
                _bodyIndex = line * 3 + 1;
                _tailIndex = line * 3 + 2;
            }
        }
        
        override public function setAsset(asset:GridAsset):Grid3
        {
            super.setAsset(asset);
            
            _headSize = _head.width;
            _tailSize = _tail.width;
            
            return this;
        }
        
        public function get direction():String { return Direction.X; }
        
        override public function set size(value:Number):void
        {
            if (value < 0) value = 0;
            
            var offset:int   = _headSize + _tailSize;
            var bodySize:int = value < offset ? 0: (value - offset)|0;
            
            _body.x     = _headSize;
            _body.width = bodySize;
            
            _tail.x = _headSize + bodySize;
            _size         = _tail.x + _tailSize;
        }
        
        override public function get position():Number
        {
            return _asset.x;
        }
        
        override public function set position(value:Number):void
        {
            _asset.x = (value + .5)|0;
        }
    }
}