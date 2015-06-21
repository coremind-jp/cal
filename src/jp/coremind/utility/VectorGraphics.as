package jp.coremind.utility
{
    import flash.display.Graphics;

    public class VectorGraphics
    {
        public static function rect(g:Graphics, w:Number, h:Number, color:uint = 0xFF0000, alpha:Number = 1, ellipse:Number = 0, x:Number = 0, y:Number = 0):void
        {
            g.beginFill(color, alpha);
            
            ellipse == 0 ?
                g.drawRect(0, 0, w, h):
                g.drawRoundRect(0, 0, w, h, ellipse, ellipse);
            
            g.endFill();
        }
    }
}