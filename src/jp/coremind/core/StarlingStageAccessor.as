package jp.coremind.core
{
    import flash.display.Stage;
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.Log;
    import jp.coremind.view.implement.starling.CalSprite;
    import jp.coremind.view.implement.starling.View;
    
    import starling.core.Starling;
    import starling.events.Event;
    import starling.events.ResizeEvent;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
    
    public class StarlingStageAccessor extends AbstractStageAccessor implements IStageAccessor
    {
        private var _starling:Starling;
        
        public function initialize(stage:Stage, completeHandler:Function):void
        {
            var appViewPort:Rectangle = Application.configure.appViewPort;
            
            var deviceViewPort:Rectangle = Application.configure.useDebugViewPort ?
                Application.configure.debugViewPort:
                new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
            
            var fit:Rectangle = RectangleUtil.fit(appViewPort, deviceViewPort, ScaleMode.SHOW_ALL);
            
            _starling  = new Starling(CalSprite, stage, fit, null, "auto", "auto");
            _starling.stage.stageWidth  = appViewPort.width;
            _starling.stage.stageHeight = appViewPort.height;
            _starling.addEventListener(starling.events.Event.ROOT_CREATED, function():void
            {
                _starling.removeEventListener(starling.events.Event.ROOT_CREATED, arguments.callee);
                
                $.loop.run();
                
                initializeLayer(_starling.root as CalSprite, CalSprite);
                
                getLayerProcessor(Layer.NAVIGATION).dispatcher = Application.globalEvent;
                getLayerProcessor(Layer.CONTENT).dispatcher    = Application.globalEvent;
                getLayerProcessor(Layer.POPUP).dispatcher      = Application.globalEvent;
                
                completeHandler();
                
//                Log.info("/appViewPort", appViewPort);
//                Log.info("/fullscreen", stage.fullScreenWidth, stage.fullScreenHeight);
//                Log.info("/stageXXX", Application.stage.stageWidth, Application.stage.stageHeight);
//                Log.info("/starlingViewPort", Starling.current.viewPort);
            });
            _starling.start();
            
//            stage.addEventListener(ResizeEvent.RESIZE, function(e:ResizeEvent):void {
//                Starling.current.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
//            });
        }
        
        override protected function get _commonView():Class
        {
            return View;
        }
    }
}