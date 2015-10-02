package jp.coremind.core
{
    import flash.display.Stage;
    import flash.geom.Rectangle;
    
    import jp.coremind.view.implement.starling.CalSprite;
    import jp.coremind.view.implement.starling.NavigationView;
    import jp.coremind.view.implement.starling.View;
    
    import starling.core.Starling;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
    
    public class StarlingViewAccessor extends AbstractViewAccessor implements IViewAccessor
    {
        private var
            _starling:Starling;
        
        public function initialize(stage:Stage, completeHandler:Function):void
        {
            StarlingMain.INITIALIZE_HANDLER = function(instance:StarlingMain):void
            {
                initializeLayer(instance, CalSprite, View);
                completeHandler();
            };
            
            var PhoneResolution:Rectangle = new Rectangle(0, 0, 640, 1136);
            var appResolution:Rectangle   = new Rectangle(0, 0, 320, 568);
            var viewPort:Rectangle = RectangleUtil.fit(appResolution, PhoneResolution, ScaleMode.SHOW_ALL);
            
            Application.SCALE_FACTOR = PhoneResolution.width / appResolution.width;
            
            _starling  = new Starling(StarlingMain, stage, viewPort);
            _starling.stage.stageWidth  = appResolution.width;
            _starling.stage.stageHeight = appResolution.height;
            _starling.start();
        }
        
        public function run():void
        {
            getLayerProcessor(Layer.NAVIGATION).push(NavigationView);
            getLayerProcessor(Layer.CONTENT).dispatcher = Application.globalEvent;
            getLayerProcessor(Layer.POPUP).dispatcher   = Application.globalEvent;
            
            var initialView:Class  = Application.configure.initialStarlingView;
            var targetLayer:String = Application.configure.enabledSplash ? Layer.POPUP: Layer.CONTENT;
            if (initialView) getLayerProcessor(targetLayer).push(initialView);
            
            Starling.current.showStats = true;
        }
    }
}
import jp.coremind.view.implement.starling.CalSprite;

class StarlingMain extends CalSprite
{
    public static var INITIALIZE_HANDLER:Function;
    public function StarlingMain()
    {
        name = "StarlingRootView";
        
        var f:Function = INITIALIZE_HANDLER;
        INITIALIZE_HANDLER = null;
        
        f(this);
    }
}