package jp.coremind.core
{
    import flash.display.DisplayObject;
    import flash.display.Stage;
    
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.implement.flash.CalSprite;
    import jp.coremind.view.implement.flash.NavigationView;
    import jp.coremind.view.implement.flash.View;

    public class FlashViewAccessor extends AbstractViewAccessor implements IViewAccessor
    {
        public function initialize(stage:Stage, completeHandler:Function):void
        {
            var root:ICalSprite = new CalSprite("FlashRootView");
            
            stage.addChild(root as DisplayObject);
            
            initializeLayer(root, CalSprite, View);
            
            completeHandler();
        }
        
        public function run():void
        {
            getLayerProcessor(Layer.NAVIGATION).push(NavigationView);
            
            var initialView:Class  = Application.configure.initialFlashView;
            if (initialView) getLayerProcessor(Layer.CONTENT).push(initialView);
        }
    }
}