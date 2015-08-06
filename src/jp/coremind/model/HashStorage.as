package jp.coremind.model
{
    public class HashStorage implements IStorage
    {
        private var _storage:Object;
        
        public function HashStorage()
        {
            reset();
        }
        
        public function reset():void
        {
            _storage = {};
        }
        
        public function create(id:String, value:*):void
        {
            $.hash.write(_storage, id, value);
        }
        
        public function read(id:String):*
        {
            return $.hash.read(_storage, id);
        }
        
        public function update(id:String, value:*):void
        {
            var keys:Array = id.split(".");
            var key:String;
            var target:Object;
            
            if (keys.length == 1)
            {
                key = keys[0];
                target = _storage;
            }
            else
            {
                key = keys.pop();
                target = $.hash.read(_storage, keys.join("."));
            }
            
            //Log.info("HashStorage::update path:", id, " key:", key, " value:", value, " storage:", target);
            target[key] = value;
        }
        
        public function de1ete(id:String):void
        {
            $.hash.del(_storage, id);
        }
    }
}