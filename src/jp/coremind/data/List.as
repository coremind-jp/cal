package jp.coremind.data
{
    public class List extends Index
    {
        protected var _source:Array;
        
        public function List(source:Array)
        {
            _source = source || [];
        }
        
        public function destory():void
        {
            _source = null;
        }
        
        public function get source():Array  { return _source; }
        
        public function get headElement():* { return getElement(head); }
        
        public function getElement(i:int):* { return _source ? _source[i]: null; }
        
        override public function refreshLength(value:int = 0):void { super.refreshLength(_source.length); }
        override public function get length():int { return _source ? _source.length: 0; }
    }
}