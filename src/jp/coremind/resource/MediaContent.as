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
        /*
        private function createBitmap(binary:ByteArray):Bitmap
        {
            var temp:ByteArray = new ByteArray();
            var png:Array = [0x89, 0x50, 0x4e, 0x47, 0xd, 0xa, 0x1a, 0xa];
            
            for (var i:int = 0; i < 8; i++) 
                if (png[i] != binary.readUnsignedByte())
                    return null;
            
            if (binary.readUnsignedInt() !== 13)//length
                return null;
            
            binary.readBytes(temp, 0, 4);
            if (temp.toString() !== "IHDR")//type
                return null;
            
            var bmpd:BitmapData = new BitmapData(
                binary.readUnsignedInt(),
                binary.readUnsignedInt(),
                true,
                0);
            
            bmpd.setPixels(bmpd.rect, binary);
            
            return new Bitmap(bmpd);
        }
        */
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