package jp.coremind.utility.helper
{
    public class StringHelper
    {
        public static const LF:String   = "\n";    //UNIX
        public static const CR:String   = "\r";    //MAC
        public static const CRLF:String = "\r\n";  //WIN
        
        public function formatLineFeed(text:String):String
        {
            return text.replace(new RegExp(CRLF+"|"+CR, "g"), LF);
        }
    }
}