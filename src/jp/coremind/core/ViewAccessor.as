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
                if (callback is Function
                &&  _STARLING_VIEW.isInitialized()
                &&  _FLASH_VIEW.isInitialized()) callback();
            };
            
            _STARLING_VIEW.initialize(stage, onComplete);
            _FLASH_VIEW.initialize(stage, onComplete);
        }
        
        protected function get starlingRoot():IViewAccessor
        {
            return _STARLING_VIEW;
        }
        
        protected function get flashRoot():IViewAccessor
        {
            return _FLASH_VIEW;
        }
    }
}