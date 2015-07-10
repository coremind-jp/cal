package jp.coremind.utility
{
    public class Log
    {
        public static var STACK_TRACE_NUM:int  = 25;
        public static var _OUTPUT:Function     = trace;
//        public static var _OUTPUT:Function     = function(...rest):void{};
        
        private static const LINE_BREAK:String = "\n";
        private static const REST_SPACE:String = " ";
        private static const INDENT:String     = " ";
        
        private static const VALID_TAG_LIST:Object = {};
        private static const LOG_GENERATOR:Object  = {};
        
        public static function addCustomTag(tag:String):void    { VALID_TAG_LIST[tag] = true; }
        public static function removeCustomTag(tag:String):void { delete VALID_TAG_LIST[tag]; }
        public static function switchCustomTag(tag:String):void { (tag in VALID_TAG_LIST) ? removeCustomTag(tag): addCustomTag(tag); }
        
        public static function custom(tag:String, ...rest):void { if (tag in VALID_TAG_LIST) _OUTPUT(tag+INDENT+_join(rest)); }
//        public static function custom(tag:String, ...rest):void { }
        
        public static function info(...rest):void    { _OUTPUT("INFO    :"+INDENT+_join(rest)); }
//        public static function debug(...rest):void   { _OUTPUT("DEBUG   :"+INDENT+_join(rest)); }
//        public static function warning(...rest):void { _OUTPUT("WARNING :"+INDENT+_join(rest)); }
//        public static function info(...rest):void    { }
        public static function debug(...rest):void   { }
        public static function warning(...rest):void { }
        
        public static function error(...rest):void
        {
            var _stackTrace:String = new Error()
                .getStackTrace()
                .split(LINE_BREAK)
                .slice(0, STACK_TRACE_NUM)
                .join(LINE_BREAK)
                .replace("Error", "StackTrace");
            
            _OUTPUT("ERROR   :"+INDENT+_join(rest)+LINE_BREAK+_stackTrace);
        }
        
        private static function _join(logList:Array):String
        {
            var _result:Array = [];
            
            for (var i:int = 0; i < logList.length; i++) 
                _result.push(_toString(logList[i]));
            
            return _result.join(REST_SPACE);
        }
        
        private static function _toString(value:*, indent:String = ""):String
        {
            return $.isPrimitive(value) ? value:
                $.isArray(value) ? LINE_BREAK + _dumpArray(value, indent + INDENT):
                _isObject(value) ? LINE_BREAK + _dumpHash(value, indent + INDENT):
                value === null ? "null":
                value === undefined ? "undefined":
                value;
        }
        
        private static function _isObject(o:*):Boolean
        {
            return String(o) === "[object Object]";
        }
        
        private static function _dumpHash(hash:Object, indent:String):String
        {
            var _result:Array = [];
            
            for (var p:String in hash)
                _result.push(indent + "["+p+"] " + _toString(hash[p], indent));
            
            return _result.join(LINE_BREAK);
        }
        
        private static function _dumpArray(array:Array, indent:String):String
        {
            var _result:Array = [];
            
            for (var i:int = 0; i < array.length; i++) 
                _result.push(indent + "["+i+"] " + _toString(array[i], indent));
            
            return _result.join(LINE_BREAK);
        }
    }
}