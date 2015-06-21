package jp.coremind.resource
{
    public class JPEGContent extends ImageContent
    {
        public function JPEGContent()
        {
            super();
        }
        
        override public function get fileExtention():String
        {
            return "jpg";
        }
    }
}