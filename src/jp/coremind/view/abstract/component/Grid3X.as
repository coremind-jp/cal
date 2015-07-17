package jp.coremind.view.abstract.component
{
    import jp.coremind.view.abstract.IDisplayObject;
    
    /**
     * Grid3クラスの可変長方向をX軸基準で実装したクラス.
     */
    public class Grid3X extends Grid3
    {
        override public function setResource(parent:IDisplayObject, head:IDisplayObject, body:IDisplayObject, tail:IDisplayObject):void
        {
            super.setResource(parent, body, head, tail);
            _headSize = _head.width;
            _tailSize = _tail.width;
        }
        
        override public function set size(value:Number):void
        {
            if (value < 0) value = 0;
            
            var offset:int   = _headSize + _tailSize;
            var bodySize:int = value < offset ? 0: (value - offset)|0;
            
            _body.x     = _headSize;
            _body.width = bodySize;
            
            _tail.x     = _headSize + bodySize;
            _size       = _tail.x + _tailSize;
        }
        
        override public function get position():Number
        {
            return _parent.x;
        }
        
        override public function set position(value:Number):void
        {
            _parent.x = (value + .5)|0;
        }
    }
}