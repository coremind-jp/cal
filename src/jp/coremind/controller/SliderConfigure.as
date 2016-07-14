package jp.coremind.controller
{
    import jp.coremind.view.layout.Size;

    public class SliderConfigure
    {
        private var
            _sliderMinPosition:Size,
            _sliderMaxPosition:Size,
            _storageIdByCurrent:String,
            _storageIdByMin:String,
            _storageIdByMax:String,
            _fractionsOmit:Boolean;
        
        public function SliderConfigure(
            slideMinPosition:Size, slideMaxPosition:Size,
            storageIdByCurrent:String, storageIdByMin:String, storageIdByMax:String, fractionsOmit:Boolean = false)
        {
            _sliderMinPosition  = slideMinPosition;
            _sliderMaxPosition  = slideMaxPosition;
            _storageIdByCurrent = storageIdByCurrent;
            _storageIdByMin     = storageIdByMin;
            _storageIdByMax     = storageIdByMax;
            _fractionsOmit      = fractionsOmit;
        }
        
        public function get sliderMinPosition():Size
        {
            return _sliderMinPosition;
        }

        public function get sliderMaxPosition():Size
        {
            return _sliderMaxPosition;
        }

        public function get storageIdByCurrent():String
        {
            return _storageIdByCurrent;
        }

        public function get storageIdByMin():String
        {
            return _storageIdByMin;
        }

        public function get storageIdByMax():String
        {
            return _storageIdByMax;
        }

        public function get fractionsOmit():Boolean
        {
            return _fractionsOmit;
        }
    }
}