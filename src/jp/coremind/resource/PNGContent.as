package jp.coremind.resource
{
    public class PngContent extends ImageContent
    {
        public function PngContent()
        {
            super();
        }
        
        override public function get fileExtention():String
        {
            return "png";
        }
    }
}