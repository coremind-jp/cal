package jp.coremind.utility
{
    public class Status
    {
        public static const TAG:String = "[Status]";
        Log.addCustomTag(TAG);
        
        public static const NONE:String          = "none";
        public static const IDLING:String        = "idling";
        public static const RUNNING:String       = "running";
        public static const FINISHED:String      = "finished";
        public static const TERMINATE:String     = "terminate";
        
        public static const SCCEEDED:String      = "succeeded";
        public static const FAILED:String        = "failed";
        public static const FATAL:String         = "fatal";
        
        public static const DOWN:String          = "down";
        public static const MOVE:String          = "move";
        public static const ROLL_OVER:String     = "rollOver";
        public static const ROLL_OUT:String      = "rollOut";
        public static const UP:String            = "up";
        public static const CLICK:String         = "click";
        public static const SELECT:String        = "select";
        public static const DESELECT:String      = "deselect";
        public static const LOCK:String          = "lock";
        public static const UNLOCK:String        = "unlock";
        public static const SYSTEM_LOCK:String   = "systemLock";
        public static const SYSTEM_UNLOCK:String = "systemUnlock";
        
        private var _value:String;
        
        public function Status(initialStatus:String = IDLING)
        {
            _value = initialStatus;
        }
        
        public function equal(expect:String, report:String = null):Boolean
        {
            if (expect === _value)
                return true;
            else
            {
                if (report !== null)
                    Log.custom(TAG, report + "Different ExpectStatus. Expect["+expect+"] Actual["+_value+"]");
                return false;
            }
        }
        
        public function update(status:String):void
        {
            _value = status;
        }
        
        public function get value():String
        {
            return _value;
        }
        
        public function toString():String
        {
            return "Staus="+_value;
        }
    }
}