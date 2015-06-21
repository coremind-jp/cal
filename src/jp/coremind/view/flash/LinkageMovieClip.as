package jp.coremind.view.flash
{
    import flash.display.MovieClip;

    public class LinkageMovieClip
    {
        private var _source:MovieClip;
        
        public function LinkageMovieClip(linkageNmae:String)
        {
            var c:Class = $.getClass(linkageNmae);
            _source = new c();
        }
        
        internal function get source():MovieClip { return _source; }
    }
}