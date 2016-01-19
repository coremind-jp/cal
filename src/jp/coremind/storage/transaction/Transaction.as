package jp.coremind.storage.transaction
{
    public class Transaction
    {
        protected var
            _position:int,
            _history:Vector.<ITransactionLog>;
        
        public function Transaction()
        {
            _history = new <ITransactionLog>[];
        }
        
        public function undo():void
        {
            if (_position > 0) _position--;
        }
        
        public function redo():void
        {
            if (_position < _history.length) _position++;
        }
        
        public function rollback():void
        {
            _history.length = _position = 0;
        }
        
        public function apply(origin:*):Diff
        {
            return new Diff(origin, null, null);
        }
    }
}