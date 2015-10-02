package jp.coremind.core
{
    import flash.display.Stage;
    
    public class ViewAccessor extends StorageAccessor
    {
        private static var _FLASH_VIEW:IViewAccessor;
        private static var _STARLING_VIEW:IViewAccessor;
        
        public static function initialize(stage:Stage, callback:Function = null):void
        {
            _STARLING_VIEW = new StarlingViewAccessor();
            _FLASH_VIEW = new FlashViewAccessor();
            
            var onComplete:Function = function():void
            {
                if (_STARLING_VIEW.isInitialized() && _FLASH_VIEW.isInitialized())
                {
                    _STARLING_VIEW.run();
                    _FLASH_VIEW.run();
                    
                    if (callback is Function) callback();
                }
            };
            
            _STARLING_VIEW.initialize(stage, onComplete);
            _FLASH_VIEW.initialize(stage, onComplete);
        }
        
        public static function enablePointerDevice():void
        {
            _STARLING_VIEW.enablePointerDevice();
            _FLASH_VIEW.enablePointerDevice();
        }
        
        public static function disablePointerDevice():void
        {
            _STARLING_VIEW.disablePointerDevice();
            _FLASH_VIEW.disablePointerDevice();
        }
        
        protected function get starling():IViewAccessor
        {
            return _STARLING_VIEW;
        }
        
        protected function get flash():IViewAccessor
        {
            return _FLASH_VIEW;
        }
    }
}