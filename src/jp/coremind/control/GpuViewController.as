package jp.coremind.control
{
    import flash.display.Stage;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.asset.Color;
    import jp.coremind.asset.EmbedAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.ViewLayer;
    import jp.coremind.view.abstract.ViewProcessor;
    import jp.coremind.view.implement.starling.NavigationView;
    import jp.coremind.view.implement.starling.RootView;
    
    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;

    public class GpuViewController extends CpuViewController
    {
        private var
            _root:Sprite,
            _starling:Starling;
        
        public function GpuViewController()
        {
            _root = new Sprite();
        }
        
        override public function disablePointerDevice():void { _root.touchable = false; }
        
        override public function enablePointerDevice():void  { _root.touchable = true; }
        
        override public function createRootLayer(stage:Stage, initialView:Class):void
        {
            StarlingMain.INITIALIZE_HANDLER = function(instance:StarlingMain):void
            {
                _root = instance;
                _root.alpha = .99999999;
                
                EmbedAsset.addCircleSource();
                
                EmbedAsset.createColorChart(
                    Color.BLUE,
                    Color.RED,
                    Color.GREEN,
                    Color.VIOLET,
                    Color.WHITE,
                    Color.GRAY);
                EmbedAsset.initialize();
                
                for (var i:int = 0; i < ViewLayer.LENGTH; i++) 
                    _viewProcessorList[i] = new ViewProcessor(_root.addChild(new RootView()) as RootView);
                
                Log.info("push navigation");
                push(ViewLayer.NAVIGATION, NavigationView);
                if (initialView)
                {
                    Log.info("push content");
                    push(ViewLayer.CONTENT, initialView);
                }
                
                //debug
                Starling.current.showStats = true;
                Starling.current.showStatsAt("right","center", 2);
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
    }
}
import starling.display.Sprite;

class StarlingMain extends Sprite
{
    public static var INITIALIZE_HANDLER:Function;
    public function StarlingMain()
    {
        var f:Function = INITIALIZE_HANDLER;
        
        INITIALIZE_HANDLER = null;
        
        f(this);
    }
}