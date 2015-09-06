package jp.coremind.resource
{
    import flash.geom.Rectangle;

    public class CircleTexture
    {
        public static const CIRCLE:int = 0;
        
        public static const QUARTER_TOP_LEFT:int     = 1;
        public static const QUARTER_BOTTOM_LEFT:int  = 2;
        public static const QUARTER_BOTTOM_RIGHT:int = 3;
        public static const QUARTER_TOP_RIGHT:int    = 4;
        
        public static const SEMI_LEFT:int   = 5;
        public static const SEMI_RIGHT:int  = 6;
        public static const SEMI_TOP:int    = 7;
        public static const SEMI_BOTTOM:int = 8;
        
        public static function createClipRect(type:int, size:int, recycle:Rectangle = null):Rectangle
        {
            recycle = recycle || new Rectangle();
            
            switch (type)
            {
                case QUARTER_TOP_LEFT:
                    recycle.width = recycle.height = size >> 1;
                    break;
                
                case QUARTER_BOTTOM_LEFT:
                    recycle.width = recycle.height = size >> 1;
                    recycle.y += recycle.height;
                    break;
                
                case QUARTER_BOTTOM_RIGHT:
                    recycle.width = recycle.height = size >> 1;
                    recycle.x += recycle.width;
                    recycle.y += recycle.height;
                    break;
                
                case QUARTER_TOP_RIGHT:
                    recycle.width = recycle.height = size >> 1;
                    recycle.x += recycle.width;
                    break;
                
                case SEMI_LEFT:
                    recycle.width  = size >> 1;
                    recycle.height = size;
                    break;
                
                case SEMI_RIGHT:
                    recycle.width  = size >> 1;
                    recycle.height = size;
                    recycle.x += recycle.width;
                    break;
                
                case SEMI_TOP:
                    recycle.width  = size;
                    recycle.height = size >> 1;
                    break;
                case SEMI_BOTTOM:
                    recycle.width  = size;
                    recycle.height = size >> 1;
                    recycle.y += recycle.height;
                    break;
            }
            
            return recycle;
        }
    }
}