package jp.coremind.utility
{
    public class Status
    {
        public static const TAG:String = "[Status]";
        Log.addCustomTag(TAG);
        
        public static const IDLING:String    = "idling";
        public static const RUNNING:String   = "running";
        public static const FINISHED:String  = "finished";
        public static const TERMINATE:String = "terminate";
        
        public static const SCCEEDED:String  = "succeeded";
        public static const FAILED:String    = "failed";
        public static const FATAL:String     = "fatal";
        
        private var _status:String;
        
        public function Status(initialStatus:String = IDLING)
        {
            _status = initialStatus;
        }
        
        public function equal(expect:String, report:String = null):Boolean
        {
            if (expect === _status)
                return true;
            else
            {
                if (report !== null)
                    Log.custom(TAG, report + "Different ExpectStatus. Expect["+expect+"] Actual["+_status+"]");
                return false;
            }
        }
        
        public function update(status:String):void
        {
            _status = status;
        }
        
        public function get status():String
        {
            return _status;
        }
    }
}