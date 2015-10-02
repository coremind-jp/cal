package jp.coremind.resource
{
    import flash.utils.ByteArray;
    
    public class XmlContent extends TextContent
    {
        public function XmlContent()
        {
        }
        
        override public function get fileExtention():String
        {
            return "xml";
        }
        
        override public function extract(f:Function, binary:ByteArray):void
        {
            $.call(f, new XML(_toUtf8(binary)));
        }
        
        override public function createFailedContent():*
        {
            return new XML();
        }
    }
}