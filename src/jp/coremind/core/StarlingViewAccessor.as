package jp.coremind.core
{
    import flash.display.Stage;
    import flash.geom.Rectangle;
    
    import jp.coremind.view.implement.starling.CalSprite;
    import jp.coremind.view.implement.starling.View;
    
    import starling.core.Starling;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
    
    public class StarlingViewAccessor extends AbstractViewAccessor implements IViewAccessor
    {
        private var _starling:Starling;
        
        public function initialize(stage:Stage, completeHandler:Function):void
        {
            StarlingMain.INITIALIZE_HANDLER = function(instance:StarlingMain):void
            {
                initializeLayer(instance, CalSprite);
                
                getLayerProcessor(Layer.NAVIGATION).dispatcher = Application.globalEvent;
                getLayerProcessor(Layer.CONTENT).dispatcher = Application.globalEvent;
                getLayerProcessor(Layer.POPUP).dispatcher   = Application.globalEvent;
                
                completeHandler();
            };
            
            var appViewPort:Rectangle = Application.configure.appViewPort;
            
            var deviceViewPort:Rectangle = Application.configure.useDebugViewPort ?
                Application.configure.debugViewPort:
                new Rectangle(0, 0, Application.stage.stageWidth, Application.stage.stageHeight);
            
            var fit:Rectangle = RectangleUtil.fit(appViewPort, deviceViewPort, ScaleMode.SHOW_ALL);
            
            _starling  = new Starling(StarlingMain, stage, fit);
            _starling.stage.stageWidth  = appViewPort.width;
            _starling.stage.stageHeight = appViewPort.height;
            _starling.start();
        }
        
        override protected function get _commonView():Class
        {
            return View;
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