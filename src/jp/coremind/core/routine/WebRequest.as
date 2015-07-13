package jp.coremind.core.routine
{
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
    
    import jp.coremind.core.Routine;
    import jp.coremind.core.Thread;
    import jp.coremind.network.RequestConfigure;
    import jp.coremind.resource.IByteArrayContent;
    import jp.coremind.utility.Log;

    public class WebRequest
    {
        private static const _CACHE:Object = {};
        private static const NOW_LOADING:Object = {};
        
        private static var _REQ_CONF:RequestConfigure;
        private static function get _DEFAULT_REQUEST_CONFIG():RequestConfigure
        {
            return _REQ_CONF ? _REQ_CONF: _REQ_CONF = new RequestConfigure({});
        }
        
        public static function dumpCacheKey():void
        {
            Log.info($.hash.createPropertyList(_CACHE));
        }
        
        public static function create(
            name:String,
            url:String,
            params:Object = null,
            config:RequestConfigure = null):Function
        {
            config = config || _DEFAULT_REQUEST_CONFIG;
            
            return config.enabledClientCache ?
                _cachableRequest(name, config, url, params):
                _nonCacheRequest(name, config, url, params);
        }
        
        private static function _cachableRequest(
            name:String,
            config:RequestConfigure,
            url:String,
            params:Object = null):Function
        {
            var _contentParser:IByteArrayContent = config.getContentParser(url);
            
            var _request:Function = function(r:Routine):void
            {
                _CACHE[url] = NOW_LOADING;
                
                var progress:Function = function(e:ProgressEvent):void
                {
                    r.updateProgress(0, e.bytesTotal, e.bytesLoaded);
                };
                
                var failed:Function = function(e:ErrorEvent):void
                {
                    r.writeData(name, _CACHE[url] = _contentParser.createFailedContent());
                    r.failed("request URL:"+url+" detail:"+e.toString());
                };
                
                var scceeded:Function = function(e:Event):void
                {
                    var _binary:ByteArray = (e.currentTarget as URLLoader).data;
                    
                    if (!_binary || _binary.length == 0)
                        r.failed("ByteArray length = 0 :" + url);
                    else
                        _contentParser.extract(function(source:*):void
                        {
                            _CACHE[url] = source;
                            r.writeData(name, _contentParser.clone(source));
                            r.scceeded("request URL:"+url);
                        }, _binary);
                };
                
                var _loader:URLLoader = new URLLoader();
                
                r.terminateHandler = _loader.close;
                
                $.event.anyone(_loader,
                    [SecurityErrorEvent.SECURITY_ERROR, IOErrorEvent.IO_ERROR, Event.COMPLETE],
                    [failed, failed, scceeded]);
                
                _loader.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
                _loader.dataFormat = URLLoaderDataFormat.BINARY;
                _loader.load(config.createURLRequest(url, params));
            };
            
            var _delegate:Function = function(r:Routine):void
            {
                var _clearInterval:Boolean = false;
                
                r.terminateHandler = function():void
                {
                    _clearInterval = true;
                };
                
                $.loop.lowResolution.setInterval(function():Boolean
                {
                    if (_CACHE[url] !== NOW_LOADING)
                    {
                        r.writeData(name, _contentParser.clone(_CACHE[url]));
                        r.scceeded("delegate URL:"+url);
                        return true;
                    }
                    return _clearInterval;
                });
            };
            
            var _reuse:Function = function(r:Routine):void
            {
                r.writeData(name, _contentParser.clone(_CACHE[url]));
                r.scceeded("reuse URL:"+url);
            };
            
            return function(r:Routine, t:Thread):void
            {
                if (url in _CACHE) _CACHE[url] === NOW_LOADING ? _delegate(r): _reuse(r);
                else _request(r);
            };
        }
        
        private static function _nonCacheRequest(
            name:String,
            config:RequestConfigure,
            url:String,
            params:Object = null):Function
        {
            return function(r:Routine, t:Thread):void
            {
                var progress:Function = function(e:ProgressEvent):void
                {
                    r.updateProgress(0, e.bytesTotal, e.bytesLoaded);
                };
                
                var failed:Function = function(e:ErrorEvent):void
                {
                    r.writeData(name, _contentParser.createFailedContent());
                    r.failed("request URL:"+url+" detail:"+e.toString());
                };
                
                var scceeded:Function = function(e:Event):void
                {
                    _contentParser.extract(function(source:*):void
                    {
                        r.writeData(name, source);
                        r.scceeded("request URL:"+url);
                    }, (e.currentTarget as URLLoader).data);
                };
                
                var _contentParser:IByteArrayContent = config.getContentParser(url);
                var _loader:URLLoader = new URLLoader();
                
                r.terminateHandler = _loader.close;
                
                $.event.anyone(_loader,
                    [SecurityErrorEvent.SECURITY_ERROR, IOErrorEvent.IO_ERROR, Event.COMPLETE],
                    [failed, failed, scceeded]);
                
                _loader.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
                _loader.dataFormat = URLLoaderDataFormat.BINARY;
                _loader.load(config.createURLRequest(url, params));
            };
        }
    }
}