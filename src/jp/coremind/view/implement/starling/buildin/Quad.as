package jp.coremind.view.implement.starling.buildin
{
    import jp.coremind.view.abstract.IDisplayObject;
    
    import starling.display.Quad;
    
    public class Quad extends starling.display.Quad implements IDisplayObject
    {
        public static function gradientFillX(q:starling.display.Quad, beginColor:uint, beginAlpha:Number, endColor:uint, endAlpha:Number):starling.display.Quad
        {
            q.setVertexColor(0, beginColor);
            q.setVertexColor(2, beginColor);
            if (beginAlpha < 1)
            {
                q.setVertexAlpha(0, beginAlpha);
                q.setVertexAlpha(2, beginAlpha);
            }
            
            q.setVertexColor(1, endColor);
            q.setVertexColor(3, endColor);
            if (endAlpha < 1)
            {
                q.setVertexAlpha(1, endAlpha);
                q.setVertexAlpha(3, endAlpha);
            }
            
            return q;
        }
        
        public static function gradientFillY(q:starling.display.Quad, beginColor:uint, beginAlpha:Number, endColor:uint, endAlpha:Number):starling.display.Quad
        {
            q.setVertexColor(0, beginColor);
            q.setVertexColor(1, beginColor);
            if (beginAlpha < 1)
            {
                q.setVertexAlpha(0, beginAlpha);
                q.setVertexAlpha(1, beginAlpha);
            }
            
            q.setVertexColor(2, endColor);
            q.setVertexColor(3, endColor);
            if (endAlpha < 1)
            {
                q.setVertexAlpha(2, endAlpha);
                q.setVertexAlpha(3, endAlpha);
            }
            
            return q;
        }
        
        public function Quad(width:Number, height:Number, color:uint=16777215, premultipliedAlpha:Boolean=true)
        {
            super(width, height, color, premultipliedAlpha);
        }
    }
}