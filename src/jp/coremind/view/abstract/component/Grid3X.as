package jp.coremind.view.abstract.component
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.resource.Color;
    import jp.coremind.resource.EmbedResource;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IStretchBar;
    import jp.coremind.view.layout.Direction;
    
    /**
     * Grid3クラスの可変長方向をX軸基準で実装したクラス.
     */
    public class Grid3X extends Grid3 implements IStretchBar
    {
        override public function setResource(parent:IDisplayObject, head:IDisplayObject, body:IDisplayObject, tail:IDisplayObject):void
        {
            super.setResource(parent, body, head, tail);
            _headSize = _head.width;
            _tailSize = _tail.width;
        }
        
        public function get direction():String { return Direction.X; }
        
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