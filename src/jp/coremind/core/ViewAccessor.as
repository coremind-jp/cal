package jp.coremind.core
{
    import flash.display.Stage;
    
    import jp.coremind.configure.ITransitionContainer;
    
    public class ViewAccessor extends StorageAccessor
    {
        private static var _FLASH_STAGE:IStageAccessor;
        private static var _STARLING_STAGE:IStageAccessor;
        
        public static function initialize(stage:Stage, callback:Function = null):void
        {
            _STARLING_STAGE = new StarlingStageAccessor();
            _FLASH_STAGE = new FlashStageAccessor();
            
            var onComplete:Function = function():void
            {
                if (callback is Function
                &&  _STARLING_STAGE.isInitialized()
                &&  _FLASH_STAGE.isInitialized()) callback();
            };
            
            _STARLING_STAGE.initialize(stage, onComplete);
            _FLASH_STAGE.initialize(stage, onComplete);
        }
        
        public static function update(transition:ITransitionContainer, terminateAsyncProcess:Boolean = true):void
        {
            if (terminateAsyncProcess)
                Application.async.terminateAll();
            
            transition.targetStage === TargetStage.STARLING ?
                _STARLING_STAGE.update(transition):
                _FLASH_STAGE.update(transition);
        }
        
        protected function get starlingRoot():IStageAccessor
        {
            return _STARLING_STAGE;
        }
        
        protected function get flashRoot():IStageAccessor
        {
            return _FLASH_STAGE;
        }
    }
}