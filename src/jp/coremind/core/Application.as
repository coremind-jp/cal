package jp.coremind.core
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.geom.Point;
    import flash.system.System;
    
    import jp.coremind.asset.Asset;
    import jp.coremind.configure.IApplicationConfigure;
    import jp.coremind.event.TransitionEvent;
    import jp.coremind.storage.Storage;
    
    import starling.core.Starling;

    public class Application
    {
        private static var _STAGE:Stage;
        public static function get stage():Stage { return _STAGE; }
        public static function get pointerX():Number { return _STAGE.mouseX / Starling.contentScaleFactor; }
        public static function get pointerY():Number { return _STAGE.mouseY / Starling.contentScaleFactor; }
        
        private static const _DEVICE_POINT:Point = new Point();
        public static function get pointer():Point
        {
            _DEVICE_POINT.setTo(
                _STAGE.mouseX / Starling.contentScaleFactor,
                _STAGE.mouseY / Starling.contentScaleFactor
            );
            return _DEVICE_POINT;
        }
        
        private static var _CONFIGURE:IApplicationConfigure;
        public static function get configure():IApplicationConfigure { return _CONFIGURE; }
        
        internal static var _DISPATCHER:IEventDispatcher = new EventDispatcher();
        public static function get globalEvent():IEventDispatcher { return _DISPATCHER; }
        
        private static const _ROUTER:Router = new Router();
        public static function get router():Router { return _ROUTER; }
        
        public static const sync:SyncProcess   = new SyncProcess();
        public static const async:AsyncProcess = new AsyncProcess();
        
        public static function initialize(deployTarget:DisplayObjectContainer, configure:IApplicationConfigure, callback:Function = null):void
        {
            _CONFIGURE = configure;
            _CONFIGURE.viewLayer.initialize();
            _CONFIGURE.statusModel.initialize();
            
            var _addedToStage:Function = function(e:Event = null):void
            {
                _STAGE = deployTarget.stage;
                _STAGE.frameRate = configure.framerate;
                
                Asset.initialize();
                
                StorageAccessor.initialize(new Storage());
                
                ViewAccessor.initialize(_STAGE, callback);
            };
            
            deployTarget.stage ?
                _addedToStage():
                $.event.anyone(deployTarget, [Event.ADDED_TO_STAGE], [_addedToStage]);
            
            //gc test
            globalEvent.addEventListener(TransitionEvent.BEGIN_TRANSITION, function(e:TransitionEvent):void {
                System.pauseForGCIfCollectionImminent(1);
            });
            globalEvent.addEventListener(TransitionEvent.END_TRANSITION, function(e:TransitionEvent):void {
                System.pauseForGCIfCollectionImminent(.25);
                System.gc();
            });
        }
    }
}