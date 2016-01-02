package jp.coremind.utility
{
    public class UrlConverter implements IUrlConverter
    {
        public function UrlConverter()
        {
        }
        
        public function getUrl(fileName:String):String
        {
            return fileName;
        }
    }
}