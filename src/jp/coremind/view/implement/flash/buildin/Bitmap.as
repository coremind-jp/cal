package jp.coremind.view.implement.flash.buildin
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    public class Bitmap extends flash.display.Bitmap implements IDisplayObject
    {
        public function Bitmap(bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
        {
            super(bitmapData, pixelSnapping, smoothing);
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
    }
}