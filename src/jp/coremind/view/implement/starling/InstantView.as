package jp.coremind.view.implement.starling
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import jp.coremind.core.Application;
    
    public class InstantView extends View
    {
        public function InstantView(controllerClass:Class)
        {
            super(controllerClass);
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
            if (controller.syncProcess.isRunning())
                return;
            
            var local:Point = globalToLocal(new Point(Application.pointerX, Application.pointerY));
            if (!hitTest(local, false))
            {
                Application.stage.removeEventListener(MouseEvent.CLICK, _onClickStage);
                controller.notifyClick(name);
            }
        }
    }
}
/*
import jp.coremind.configure.IViewTransition;
import jp.coremind.configure.LayerType;
import jp.coremind.configure.ViewConfigure;
import jp.coremind.configure.ViewInsertType;

class InstantViewTransition implements IViewTransition
{
    private var _viewId:String;
    
    public function InstantViewTransition(viewId:String)
    {
        _viewId = viewId;
    }
    
    public function get layerType():String
    {
        return LayerType.STARLING;
    }
    
    public function getViewConfigure(layer:String):ViewConfigure
    {
        return new ViewConfigure(ViewInsertType.REQUEST_REMOVE, [_viewId]);
    }
}
*/