package jp.coremind.view.starling.component
{
    import starling.display.DisplayObject;

    public class Grid3Y extends Grid3
    {
        override public function setElement(body:DisplayObject, head:DisplayObject, tail:DisplayObject):void
        {
            super.setElement(body, head, tail);
            _headSize = _head.height;
        }
        
        override public function set size(size:Number):void
        {
            _body.height = _size = size;
            
            _head.y = 0;
            _body.y = _headSize;
            _tail.y = _body.y + size;
        }
        
        override public function get size():Number
        {
            return _body.height;
        }
    }
}