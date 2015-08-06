package jp.coremind.view.layout
{
    import flash.geom.Rectangle;

    public class AbstractLayout
    {
        protected var
            _rect:Rectangle;
        
        public function AbstractLayout(temporaryRect:Rectangle)
        {
            _rect = temporaryRect;
        }
        
        public function destroy():void
        {
            _rect = null;
        }
    }
}