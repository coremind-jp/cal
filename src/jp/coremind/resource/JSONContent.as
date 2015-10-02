package jp.coremind.resource
{
    import flash.utils.ByteArray;

    public class JsonContent extends TextContent
    {
        public function JsonContent()
        {
            super();
        }
        
        override public function get fileExtention():String
        {
            return "json";
        }
        
        override public function extract(f:Function, binary:ByteArray):void
        {
            $.call(f, JSON.parse(_toUtf8(binary)));
        }
        
        override public function createFailedContent():*
        {
            return {};
        }
    }
}