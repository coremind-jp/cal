package jp.coremind.view.implement.starling
{
    import flash.events.MouseEvent;
    
    import jp.coremind.core.Application;
    import jp.coremind.core.TransitionContainer;
    import jp.coremind.core.ViewAccessor;

    public class InstantView extends View
    {
        public function InstantView()
        {
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
            
            Application.stage.removeEventListener(MouseEvent.CLICK, _onClickStage);
            ViewAccessor.update(TransitionContainer.restore());
        }
    }
}