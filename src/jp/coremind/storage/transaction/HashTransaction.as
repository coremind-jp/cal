package jp.coremind.storage.transaction
{
    public class HashTransaction extends Transaction
    {
        public function HashTransaction()
        {
            super();
        }
        
        public function add(value:*, key:String):HashTransaction
        {
            _history.push(new HashAdd(value).setToData(key));
            _position++;
            
            return this;
        }
        
        public function remove(key:String):HashTransaction
        {
            _history.push(new HashRemove(key));
            _position++;
            
            return this;
        }
        
        public function update(value:*, key:*):HashTransaction
        {
            _history.push(new HashUpdate(value).setToData(key));
            _position++;
            
            return this;
        }
        
        override public function apply(origin:*):Diff
        {
            var clonedHash:Object = $.clone(origin);
            var info:DiffHashInfo = new DiffHashInfo();
            var diff:Diff = new Diff(clonedHash, null, info);
            
            for (var i:int = 0; i < _position; i++)
                _history[i].apply(diff);
            
            return diff;
        }
    }
}