package jp.coremind.core
{
    import flash.display.DisplayObject;
    import flash.display.Stage;
    
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.implement.flash.CalSprite;
    import jp.coremind.view.implement.flash.View;

    public class FlashStageAccessor extends AbstractStageAccessor implements IStageAccessor
    {
        public function initialize(stage:Stage, completeHandler:Function):void
        {
            var root:ICalSprite = new CalSprite("FlashRootView");
            
            stage.addChild(root as DisplayObject);
            
            initializeLayer(root, CalSprite);
            
            completeHandler();
        }
        
        override protected function get _commonView():Class
        {
            return View;
        }
    }
}