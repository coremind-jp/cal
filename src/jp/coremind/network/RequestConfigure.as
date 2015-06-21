package jp.coremind.network
{
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    
    import jp.coremind.resource.ContentParser;
    import jp.coremind.resource.IByteArrayContent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.validation.HashValidation;

    public class RequestConfigure
    {
        private static const NO_CACHE_KEY:String   = "noCache";
        private static const NO_CACHE_VALUE:String = new Date().time.toFixed();
        
        private var
            _validater:HashValidation,
            _headers:Array,
            _method:String,
            _cacheDisabled:Boolean,
            _paramsParser:Function,
            _contentParser:String,
            _useClientCache:Boolean;
        
        public function RequestConfigure(validationDefine:Object)
        {
            _validater      = new HashValidation(validationDefine || {});
            _headers        = null;
            _method         = URLRequestMethod.GET;
            _cacheDisabled  = false;
            _paramsParser   = null;
            _contentParser  = ContentParser.AUTO;
            _useClientCache = true;
        }
        
        public function headers(value:Array):RequestConfigure
        {
            _headers = value;
            return this;
        }
        
        public function method(value:String):RequestConfigure
        {
            _method = value;
            return this;
        }
        
        public function cacheDisabled(value:Boolean):RequestConfigure
        {
            _cacheDisabled = value;
            return this;
        }
        
        public function paramsParser(parser:Function):RequestConfigure
        {
            _paramsParser = parser;
            return this;
        }
        
        public function contentParser(value:String):RequestConfigure
        {
            _contentParser = value;
            return this;
        }
        
        public function get enabledClientCache():Boolean { return _useClientCache; }
        public function useClientCache(value:Boolean):RequestConfigure
        {
            _useClientCache = value;
            return this;
        }
        
        public function getContentParser(url:String = null):IByteArrayContent
        {
            return ContentParser.getParser(_contentParser, url);
        }
        
        public function createURLRequest(url:String, params:Object = null):URLRequest
        {
            var _req:URLRequest = new URLRequest(url);
            
            _req.method         = _method;
            _req.data           = _parseParams(params);
            _req.requestHeaders = _headers;
            
            return _req;
        }
        
        private function _parseParams(params:Object):*
        {
            if (_validater.exec(params))
            {
                var _params:Object = $.clone(params);
                
                if (_cacheDisabled)
                    $.hash.write(_params, NO_CACHE_KEY, NO_CACHE_VALUE);
                
                return _paramsParser is Function ? _paramsParser(_params): _params;
            }
            else
            {
                Log.error("invalid parameter.");
                return "";
            }
        }
    }
}