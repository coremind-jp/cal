package jp.coremind.resource
{
    public class PNGContent extends ImageContent
    {
        public function PNGContent()
        {
            super();
        }
        
        override public function get fileExtention():String
        {
            return "png";
        }
    }
}