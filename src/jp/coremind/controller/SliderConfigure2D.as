package jp.coremind.controller
{
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.view.layout.Size;

    public class SliderConfigure2D
    {
        private var
            _horizontal:SliderConfigure,
            _vertical:SliderConfigure,
            _slideArea:Rectangle;
        
        public function SliderConfigure2D()
        {
        }
        
        public function enableHorizontalSlide(
            slideMinPosition:Size, slideMaxPosition:Size,
            storageIdByCurrent:String, storageIdByMin:String, storageIdByMax:String,
            fractionsOmit:Boolean = false):SliderConfigure2D
        {
            _horizontal = new SliderConfigure(
                slideMinPosition, slideMaxPosition,
                storageIdByCurrent, storageIdByMin, storageIdByMax,
                fractionsOmit);
            
            return this;
        }
        public function isEnabledHorizontalSlide():Boolean { return Boolean(_horizontal); }
        public function get horizontal():SliderConfigure   { return _horizontal; }
        
        public function enableVerticalSlide(
            slideMinPosition:Size, slideMaxPosition:Size,
            storageIdByCurrent:String, storageIdByMin:String, storageIdByMax:String,
            fractionsOmit:Boolean = false):SliderConfigure2D
        {
            _vertical = new SliderConfigure(
                slideMinPosition, slideMaxPosition,
                storageIdByCurrent, storageIdByMin, storageIdByMax,
                fractionsOmit);
            
            return this;
        }
        public function isEnabledVerticalSlide():Boolean { return Boolean(_vertical); }
        public function get vertical():SliderConfigure   { return _vertical; }
        
        
        public function createSlideAreaRectangle():void
        {
            _slideArea = new Rectangle();
            
            if (isEnabledHorizontalSlide())
            {
                var width:Number = Application.configure.appViewPort.width;
                var minH:Number = _horizontal.sliderMinPosition.calc(width);
                var maxH:Number = _horizontal.sliderMaxPosition.calc(width);
                
                _slideArea.x = minH;
                _slideArea.width = maxH;
            }
            
            if (isEnabledVerticalSlide())
            {
                var height:Number = Application.configure.appViewPort.height;
                var minV:Number = _vertical.sliderMinPosition.calc(height);
                var maxV:Number = _vertical.sliderMaxPosition.calc(height);
                
                _slideArea.y = minV;
                _slideArea.height = maxV;
            }
        }
        public function get slideArea():Rectangle { return _slideArea; }
    }
}