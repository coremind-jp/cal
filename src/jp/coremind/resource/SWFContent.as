package jp.coremind.resource
{
    import flash.display.MovieClip;

    public class SwfContent extends MediaContent
    {
        public function SwfContent()
        {
            super();
        }
        
        override public function get fileExtention():String
        {
            return "swf";
        }
        
        override public function createFailedContent():*
        {
            var s:MovieClip = new MovieClip();
            s.graphics.beginFill(0xFF0000);
            s.graphics.drawRect(0, 0, 100, 100);
            s.graphics.endFill();
            return s;
        }
    }
}