package jp.coremind.core
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    import jp.coremind.control.Controller;
    import jp.coremind.model.Storage;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.view.builder.IElementBluePrint;
    import jp.coremind.view.builder.IPartsBluePrint;
    
    import starling.core.Starling;

    public class Application
    {
        public static const VIEW_PORT:Rectangle = new Rectangle(0, 0, 320, 568);
        public static var SCALE_FACTOR:Number = 1;
        
        public static function get pointerX():Number { return _STAGE.mouseX / Starling.contentScaleFactor; }
        public static function get pointerY():Number { return _STAGE.mouseY / Starling.contentScaleFactor; }
        
        private static var _ENABLED_LOG:Boolean = false;
        private static function enabledLog(boolean:Boolean):void { _ENABLED_LOG = boolean; }
        
        private static var _STAGE:Stage;
        public static function get stage():Stage { return _STAGE; }
        
        private static const _DEBUG_SHAPE:Shape = new Shape();
        public static function get debugShape():Shape { return _DEBUG_SHAPE; }
        
        private static var _ELEMENT_BLUE_PRINT:IElementBluePrint;
        public static function get elementBluePrint():IElementBluePrint { return _ELEMENT_BLUE_PRINT; }
        
        private static var _PARTS_BLUE_PRINT:IPartsBluePrint;
        public static function get partsBlulePrint():IPartsBluePrint { return _PARTS_BLUE_PRINT; }
        
        public static function initialize(
            deployTarget:Sprite,
            elementBluePrint:IElementBluePrint,
            partsBluePrint:IPartsBluePrint,
            initialGpuView:Class = null,
            initialCpuView:Class = null):void
        {
            var _addedToStage:Function = function(e:Event = null):void
            {
                _ELEMENT_BLUE_PRINT = elementBluePrint;
                _PARTS_BLUE_PRINT   = partsBluePrint;
                
                _STAGE = deployTarget.stage;
                _STAGE.frameRate = 60;
                _STAGE.addChildAt(_DEBUG_SHAPE, 0);
                
                //model
                StorageAccessor.initialize(new Storage());
                
                //controller (and view)
                Controller.initialize(_STAGE, initialGpuView, initialCpuView);
            };
            
            deployTarget.stage ?
                _addedToStage():
                $.event.anyone(deployTarget, [Event.ADDED_TO_STAGE], [_addedToStage]);
        }
    }
}