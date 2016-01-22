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
            pushLog(new HashAdd(value, key));
            return this;
        }
        
        public function remove(key:String):HashTransaction
        {
            pushLog(new HashRemove(key));
            return this;
        }
        
        public function update(value:*, key:*):HashTransaction
        {
            pushLog(new HashUpdate(value, key));
            return this;
        }
        
        override public function apply(origin:*):Diff
        {
            var clonedHash:Object = $.clone(origin);
            var diff:Diff = new Diff(clonedHash, null, new DiffHashInfo());
            
            for (var i:int = 0; i < _position; i++)
                _history[i].apply(diff);
            
            return diff;
        }
    }
}