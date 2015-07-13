package jp.coremind.view.starling.component
{
    import starling.display.DisplayObject;

    public class Grid3X extends Grid3
    {
        override public function setElement(body:DisplayObject, head:DisplayObject, tail:DisplayObject):void
        {
            super.setElement(body, head, tail);
            _headSize = _head.width;
        }
        
        override public function set size(size:Number):void
        {
            _body.width = _size = size;
            
            _head.x = 0;
            _body.x = _headSize;
            _tail.x = _body.x + size;
        }
    }
}