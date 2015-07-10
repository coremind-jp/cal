package jp.coremind.model.storage
{
    import jp.coremind.utility.Log;

    public class HashStorage extends Storage
    {
        private var _storage:Object;
        
        public function HashStorage() {}
        
        override public function reset():void
        {
            _storage = {};
        }
        
        override public function create(id:String, value:*):void
        {
            $.hash.write(_storage, id, value);
        }
        
        override public function read(id:String):*
        {
            return $.hash.read(_storage, id);
        }
        
        override public function update(id:String, value:*):void
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
        
        override public function de1ete(id:String):void
        {
            $.hash.del(_storage, id);
        }
    }
}