package jp.coremind.view.implement.starling
{
    import flash.display.Stage;
    import flash.events.Event;
    
    import jp.coremind.data.Progress;
    import jp.coremind.view.abstract.ViewContainer;
    import jp.coremind.view.implement.flash.ViewControl;
    
    import starling.core.Starling;
    

    public class ViewControl extends jp.coremind.view.implement.flash.ViewControl
    {
        private var _starling:Starling;
        
        public function ViewControl() {}
        
        override public function bindRootLayer(stage:Stage):void
        {
            _starling  = new Starling(RootView, stage);
            _starling.start();
            
            $.loop.highResolution.pushHandler(
                10000,
                function(p:Progress):void {},
                function(p:Progress):Boolean
                {
                    if (RootView.instance)
                    {
                        _container = new ViewContainer(RootView.instance);
                        dispatchEvent(new Event(Event.INIT));
                    }
                    return RootView.instance;
                });
        }
    }
}