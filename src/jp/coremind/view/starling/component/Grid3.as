package jp.coremind.view.starling.component
{
    import starling.display.DisplayObject;
    import jp.coremind.view.starling.ElementContainer;

    public class Grid3 extends ElementContainer
    {
        protected var
            _size:Number,
            _headSize:Number,
            _head:DisplayObject,
            _body:DisplayObject,
            _tail:DisplayObject;
        
        public function Grid3()
        {
            _size = 0;
        }
        
        public function setResource(body:DisplayObject, head:DisplayObject, tail:DisplayObject):void
        {
            addChild(_head = head);
            addChild(_body = body);
            addChild(_tail = tail);
        }
        
        public function set size(size:Number):void
        {
        }
        
        public function get size():Number
        {
            return _size;
        }
    }
}