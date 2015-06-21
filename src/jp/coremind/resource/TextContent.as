package jp.coremind.resource
{
    import flash.utils.ByteArray;
    
    public class TextContent implements IByteArrayContent
    {
        public function TextContent()
        {
        }
        
        public function get fileExtention():String
        {
            return "txt";
        }
        
        public function extract(f:Function, binary:ByteArray):void
        {
            $.call(f, _toUtf8(binary));
        }
        
        public function clone(source:*):*
        {
            return $.clone(source);
        }
        
        public function createFailedContent():*
        {
            return "content not found.";
        }
        
        protected function _toUtf8(binary:ByteArray):String
        {
            return $.string.formatLineFeed(binary.readUTFBytes(binary.length));
        }
    }
}