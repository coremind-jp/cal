config namespace CAL;

package jp.coremind.core
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.geom.Rectangle;
    import flash.system.System;
    
    import jp.coremind.asset.Asset;
    import jp.coremind.configure.IApplicationConfigure;
    import jp.coremind.event.ViewTransitionEvent;
    import jp.coremind.storage.Storage;
    
    import starling.core.Starling;

    public class Application
    {
        public static const VIEW_PORT:Rectangle = new Rectangle(0, 0, 320, 568);
        public static var SCALE_FACTOR:Number = 1;
        
        public static function get pointerX():Number { return _STAGE.mouseX / Starling.contentScaleFactor; }
        public static function get pointerY():Number { return _STAGE.mouseY / Starling.contentScaleFactor; }
        
        private static var _STAGE:Stage;
        public static function get stage():Stage { return _STAGE; }
        
        private static var _CONFIGURE:IApplicationConfigure;
        public static function get configure():IApplicationConfigure { return _CONFIGURE; }
        
        internal static var _DISPATCHER:IEventDispatcher = new EventDispatcher();
        public static function get globalEvent():IEventDispatcher { return _DISPATCHER; }
        
        public static function initialize(deployTarget:Sprite, configure:IApplicationConfigure, callback:Function = null):void
        {
            _CONFIGURE = configure;
            
            var _addedToStage:Function = function(e:Event = null):void
            {
                _STAGE = deployTarget.stage;
                _STAGE.frameRate = 60;
                _STAGE.addChildAt(_DEBUG_SHAPE, 0);
                
                Asset.initialize();
                
                StorageAccessor.initialize(new Storage());
                
                ViewAccessor.initialize(_STAGE, callback);
            };
            
            deployTarget.stage ?
                _addedToStage():
                $.event.anyone(deployTarget, [Event.ADDED_TO_STAGE], [_addedToStage]);
            
            //gc test
            globalEvent.addEventListener(ViewTransitionEvent.BEGIN_TRANSITION, function(e:ViewTransitionEvent):void {
                System.pauseForGCIfCollectionImminent(1);
            });
            globalEvent.addEventListener(ViewTransitionEvent.END_TRANSITION, function(e:ViewTransitionEvent):void {
                System.pauseForGCIfCollectionImminent(.25);
                System.gc();
            });
        }
        
        private static const _DEBUG_SHAPE:Shape = new Shape();
        public static function get debugShape():Shape { return _DEBUG_SHAPE; }
    }
}