package jp.coremind.resource
{
    public class JpegContent extends ImageContent
    {
        public function JpegContent()
        {
            super();
        }
        
        override public function get fileExtention():String
        {
            return "jpg";
        }
    }
}