package jp.coremind.view.implement.starling.buildin
{
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.geom.Matrix;
    
    import jp.coremind.view.abstract.IDisplayObject;
    
    import starling.display.Image;
    import starling.textures.Texture;
    import starling.utils.Color;
    
    public class Image extends starling.display.Image implements IDisplayObject
    {
        private static const M:Matrix = new Matrix();
        private static const S:Shape = new Shape();
        private static var G:Graphics = S.graphics;
        
        public static function createCircle(size:Number, beginColor:uint, useGradient:Boolean = false, endColor:uint = 0):Texture
        {
            var wh:Number = size << 1;
            var bmpd:BitmapData = new BitmapData(wh, wh, true, 0);
            var beginAlpha:Number = Color.getAlpha(beginColor) / 255;
            
            if (useGradient)
            {
                var endAlpha:Number = Color.getAlpha(endColor) / 255;
                M.createGradientBox(wh, wh);
                G.beginGradientFill(GradientType.RADIAL, [beginColor, endColor], [beginAlpha, endAlpha], [0, 255], M);
            }
            else
                G.beginFill(beginColor, beginAlpha);
            
            G.drawCircle(size, size, size);
            G.endFill();
            
            bmpd.draw(S);
            G.clear();
            return Texture.fromBitmapData(bmpd, false);
        }
        
        public function Image(texture:Texture)
        {
            super(texture);
        }
    }
}