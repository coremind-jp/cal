package jp.coremind.view.implement.starling
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import jp.coremind.core.Application;
    import jp.coremind.core.TransitionContainer;
    import jp.coremind.core.ViewAccessor;
    
    import starling.display.DisplayObject;
    
    public class PopupView extends View
    {
        public function PopupView()
        {
        }
        
        override public function destroy(withReference:Boolean=false):void
        {
            Application.stage.removeEventListener(MouseEvent.CLICK, _onClickStage);
            
            super.destroy(withReference);
        }
        
        override public function ready():void
        {
            super.ready();
            
            Application.stage.addEventListener(MouseEvent.CLICK, _onClickStage);
        }
        
        private function _onClickStage(e:MouseEvent):void
        {
            if (Application.sync.isRunning())
                return;
            
            var local:Point = globalToLocal(new Point(Application.pointerX, Application.pointerY));
            var hitObject:DisplayObject = hitTest(local, false);
            if (!hitObject || hitObject is BackgroundImage)
            {
                Application.stage.removeEventListener(MouseEvent.CLICK, _onClickStage);
                ViewAccessor.update(TransitionContainer.restore());
            }
        }
    }
}