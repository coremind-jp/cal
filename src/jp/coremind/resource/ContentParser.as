package jp.coremind.resource
{
    import jp.coremind.utility.Log;

    public class ContentParser
    {
        public static const AUTO:String = "auto";
        public static const JSON:String = "json";
        public static const  CSV:String = "csv";
        public static const  TXT:String = "txt";
        public static const  PNG:String = "png";
        public static const  JPG:String = "jpg";
        public static const  SWF:String = "swf";
        
        public static const FILE_EXTENTION_REGEXP:RegExp = new RegExp("\.([a-zA-Z]{3,4})$", "i");
        
        private static var _PARSER_LIST:Object = {
            json: new JSONContent(),
            csv : new CSVContent(),
            txt : new TextContent(),
            png : new PNGContent(),
            jpg : new JPEGContent(),
            jpeg: new JPEGContent(),
            swf : new SWFContent()
        };
        
        public static function getParser(type:String, uri:String = null):IByteArrayContent
        {
            return type === AUTO ? _findParser(uri): _PARSER_LIST[type];
        }
        
        private static function _findParser(uri:String):IByteArrayContent
        {
            var _match:Array = FILE_EXTENTION_REGEXP.exec(uri);
            if (_match && _match[1] in _PARSER_LIST)
            {
                return _PARSER_LIST[_match[1]];
            }
            else
            {
                Log.error("Unknown File Extension. " + uri);
                return _PARSER_LIST[TXT];
            }
        }
    }
}