package jp.coremind.view.abstract.component
{
    import jp.coremind.view.abstract.IDisplayObject;
    
    /**
     * Grid3クラスの可変長方向をY軸基準で実装したクラス.
     */
    public class Grid3Y extends Grid3
    {
        override public function setResource(parent:IDisplayObject, head:IDisplayObject, body:IDisplayObject, tail:IDisplayObject):void
        {
            super.setResource(parent, body, head, tail);
            _headSize = _head.height;
            _tailSize = _tail.height;
        }
        
        override public function set size(value:Number):void
        {
            if (value < 0) value = 0;
            
            var offset:int   = _headSize + _tailSize;
            var bodySize:int = value < offset ? 0: (value - offset)|0;
            
            _body.y      = _headSize;
            _body.height = bodySize;
            
            _tail.y      = _headSize + bodySize;
            _size        = _tail.y + _tailSize;
        }
        
        override public function get position():Number
        {
            return _parent.y;
        }
        
        override public function set position(value:Number):void
        {
            _parent.y = (value + .5)|0;;
        }
    }
}