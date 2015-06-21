package jp.coremind.resource
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.system.ApplicationDomain;
    import flash.system.ImageDecodingPolicy;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    
    public class MediaContent implements IByteArrayContent
    {
        private static var LOADER_CONTEXT:LoaderContext = new LoaderContext();
        LOADER_CONTEXT.applicationDomain   = ApplicationDomain.currentDomain;
        LOADER_CONTEXT.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
        
        public function MediaContent()
        {
        }
        
        public function get fileExtention():String
        {
            return null;
        }
        
        public function extract(f:Function, binary:ByteArray):void
        {
            var _loader:Loader = new Loader();
            
            $.event.anyone(_loader.contentLoaderInfo,
                [Event.COMPLETE], [function(e:Event):void
                {
                    $.call(f, (e.currentTarget as LoaderInfo).content);
                    _loader.unloadAndStop();
                }]);
            
            _loader.loadBytes(binary, LOADER_CONTEXT);
        }
        
        public function clone(source:*):*
        {
            return $.clone(source);
        }
        
        public function createFailedContent():*
        {
            return null;
        }
    }
}