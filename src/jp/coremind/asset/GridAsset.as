package jp.coremind.asset
{
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.implement.starling.buildin.Image;
    import jp.coremind.view.implement.starling.buildin.MovieClip;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    
    public class GridAsset extends Sprite
    {
        private static const _COPY_PROP_LIST:Vector.<String> = new <String>["x", "y", "width", "height", "scaleX", "scaleY"];
        
        public static const GRID3_LINE:int = -1;
        public static const GRID9_LINE_HEAD:int = 0;
        public static const GRID9_LINE_BODY:int = 1;
        public static const GRID9_LINE_TAIL:int = 2;
        
        public function GridAsset()
        {
            super();
        }
        
        protected function _copyProperty(from:Image, to:Image):void
        {
            for (var i:int = 0, len:int = _COPY_PROP_LIST.length; i < len; i++) 
                to[_COPY_PROP_LIST[i]] = from[_COPY_PROP_LIST[i]];
        }
        
        internal function image(i:int):Image    { return getChildAt(i) as Image; }
        internal function mc(i:int):MovieClip   { return getChildAt(i) as MovieClip; }
        public function body():IDisplayObject   { return getChildAt(numChildren == 3 ? 1: 4) as IDisplayObject; }
    }
}