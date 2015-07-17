package jp.coremind.core
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    
    import jp.coremind.configure.ApplicationConfigure;
    import jp.coremind.utility.Log;
    import jp.coremind.view.implement.flash.ViewControl;
    import jp.coremind.view.implement.starling.ViewControl;
    
    import starling.core.Starling;
    import jp.coremind.model.StorageControl;

    public class Application
    {
        private static var _ENABLED_LOG:Boolean = false;
        private static function enabledLog(boolean:Boolean):void
        {
            _ENABLED_LOG = boolean;
        }
        
        private static var _VIEW_CONTROL_STARLING:jp.coremind.view.implement.starling.ViewControl;
        public static function get contentView():jp.coremind.view.implement.starling.ViewControl { return _VIEW_CONTROL_STARLING; }
        
        private static var _VIEW_CONTROL_FLASH:jp.coremind.view.implement.flash.ViewControl;
        public static function get uiView():jp.coremind.view.implement.flash.ViewControl { return _VIEW_CONTROL_FLASH; }
        
        private static var _STAGE:Stage;
        public static function initialize(useStarling:Boolean, deploymentTarget:Sprite):void
        {
            if (ApplicationConfigure.NAVI_VALIDATOR)
            {
                Log.error("ApplicationConfigure.NAVI_VALIDATOR is undefined.");
                return;
            }
            
            if (_VIEW_CONTROL_FLASH)
            {
                Log.error("already running Application.");
                return;
            }
            
            _VIEW_CONTROL_FLASH = new jp.coremind.view.implement.flash.ViewControl();
            
            if (useStarling)
                _VIEW_CONTROL_STARLING = new jp.coremind.view.implement.starling.ViewControl();
            
            var _bind:Function = function(e:Event = null):void
            {
                _STAGE = deploymentTarget.stage;
                _STAGE.addChildAt(_DEBUG_SHAPE, 0);

                _VIEW_CONTROL_FLASH.bindRootLayer(_STAGE);
                
                if (useStarling)
                {
                    _VIEW_CONTROL_STARLING.bindRootLayer(_STAGE);
                    Starling.current.showStats = true;
                    Starling.current.showStatsAt("right","bottom",2);
                    
                    _STAGE.frameRate = 60;
                }
            };
            
            deploymentTarget.stage ?
                _bind():
                $.event.anyone(deploymentTarget, [Event.ADDED_TO_STAGE], [_bind]);
        }
        
        public static const storage:StorageControl = new StorageControl();
        
        public static function get stage():Stage { return _STAGE; }
        
        private static const _DEBUG_SHAPE:Shape = new Shape();

        public static function get debugShape():Shape { return _DEBUG_SHAPE; }
    }
}