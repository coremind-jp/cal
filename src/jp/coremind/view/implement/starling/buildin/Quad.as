package jp.coremind.view.implement.starling.buildin
{
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    import starling.display.Quad;
    
    public class Quad extends starling.display.Quad implements IDisplayObject
    {
        public function Quad(width:Number, height:Number, color:uint=16777215, premultipliedAlpha:Boolean=true)
        {
            super(width, height, color, premultipliedAlpha);
        }
        
        public function get parentDisplay():IDisplayObjectContainer
        {
            return parent as IDisplayObjectContainer;
        }
    }
}