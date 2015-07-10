package jp.coremind.model
{
    public class TransactionLog
    {
        private static const _NONE:String          = "none";
        private static const _ADD_VALUE:String     = "addValue";
        private static const _UPDATE_VALUE:String  = "updateValue";
        private static const _REMOVE_VALUE:String  = "removeValue";
        private static const _FILTER_VALUE:String  = "filterValue";
        private static const _RESTORE_VALUE:String = "restoreValue";
        
        private var
            _action:String,
            _id:*,
            _value:*;
        
        public function TransactionLog(value:*)
        {
            _action = _NONE;
            _id     = null;
            _value  = value;
        }
        
        public function get value():* { return _value; }
        internal function get key():String { return String(_id); }
        internal function get index():int  { return int(_id); }
        
        public function added():Boolean { return _action === _ADD_VALUE; }
        public function add(id:* = null):TransactionLog
        {
            _action = _ADD_VALUE;
            _id = key;
            return this;
        }
        
        public function updated():Boolean { return _action === _UPDATE_VALUE; }
        public function update(id:* = null):TransactionLog
        {
            _action = _UPDATE_VALUE;
            _id = id;
            return this;
        }
        
        public function removed():Boolean { return _action === _REMOVE_VALUE; }
        public function remove(id:* = null):TransactionLog
        {
            _action = _REMOVE_VALUE;
            _id = id;
            return this;
        }
        
        public function filtered():Boolean { return _action === _FILTER_VALUE; }
        public function filtering(id:* = null):TransactionLog
        {
            _action = _FILTER_VALUE;
            _id = id;
            return this;
        }
        
        public function restored():Boolean { return _action === _RESTORE_VALUE; }
        public function restore(id:* = null):TransactionLog
        {
            _action = _RESTORE_VALUE;
            _id = id;
            return this;
        }
        
        public function toString():String
        {
            return "[TransactionLog] action:"+_action + " id:"+_id;
        }
    }
}