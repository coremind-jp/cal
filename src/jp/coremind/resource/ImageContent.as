package jp.coremind.resource
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    public class ImageContent extends MediaContent
    {
        public static var NOT_FOUND_IMAGE:Bitmap = new Bitmap(new BitmapData(100, 100, false, 0xFF0000));
        
        public function ImageContent()
        {
            super();
        }
        
        override public function clone(source:*):*
        {
            return new Bitmap((source as Bitmap).bitmapData.clone());
        }
        
        override public function createFailedContent():*
        {
            return new Bitmap(NOT_FOUND_IMAGE.bitmapData);
        }
    }
}