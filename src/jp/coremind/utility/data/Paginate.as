package jp.coremind.utility.data
{
    public class Paginate extends Index
    {
        private var
            _elementNum:int,
            _list:List;
        
        public function Paginate(source:Array, elementNum:int = 1)
        {
            _list        = new List(source);
            _elementNum  = elementNum < 1 ? 1: elementNum;
            
            refreshLength();
        }
        
        public function destory():void
        {
            _list.destory();
            _list = null;
        }
        
        public function get source():Array   { return _list.source; }
        
        public function get elementNum():int { return _elementNum; }
        
        public function getElementList():Array
        {
            var _result:Array = [];
            var _to:int = head * _elementNum;
            
            if (length > 0)
            {
                _list.jump(_to);
                _result.push(_list.headElement);
                
                for (var i:int = 1; i < _elementNum; i++) 
                    if ((_list.next())) _result.push(_list.headElement)
                    else break;
            }
            
            return _result;
        }
        
        override public function refreshLength(value:int = 0):void { super.refreshLength(length); }
        override public function get length():int { return _list ? Math.ceil(_list.length / _elementNum): 0; }
    }
}