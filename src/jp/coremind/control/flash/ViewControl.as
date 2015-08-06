package jp.coremind.control.flash
{
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import jp.coremind.core.ApplicationConfigure;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.abstract.ViewContainer;
    import jp.coremind.view.implement.flash.Navigation;
    import jp.coremind.view.implement.flash.View;
    import jp.coremind.view.implement.flash.buildin.Sprite;
    import jp.coremind.control.ILayerControl;

    public class ViewControl extends EventDispatcher
    {
        protected var
            _container:ILayerControl;
        
        private var
            _message:Sprite,
            _navigation:Navigation,
            _dialog:Sprite;
        
        public function ViewControl()
        {
        }
        
        private function _createView(cls:*):IView
        {
            var c:Class = _getClass(cls);
            return new c();
        }
        
        private function _getClass(cls:*):Class
        {
            return cls is Class ? cls: $.getClassByName(cls);
        }
        
        public function bindRootLayer(stage:Stage):void
        {
            var _contentRoot:View = new View();
            
            _container = new ViewContainer(_contentRoot);
            //            _messagePopup  = _addLayer("MESSAGE_POPUP_LAYER");
            
            _navigation = new Navigation();
            
            //            _dialogPopup   = _addLayer("DIALOG_POPUP_LAYER");
            var _root:Sprite = new Sprite();
            _root.addChild(_contentRoot);
            _root.addChild(_navigation);
            
            stage.addChild(_root);
            dispatchEvent(new Event(Event.INIT));
        }
        
        public function reset(cls:*, parallel:Boolean = false):void
        {
            var p:Process = new Process("Reset Process");
            
            _container.bindReset(p, _createView(cls), parallel);
            
            p.exec();
        }
        
        public function swap(cls:*, parallel:Boolean = false):void
        {
            var i:int = _container.getViewIndexByClass(_getClass(cls));
            
            if (i == -1)
                push(cls, parallel);
            else
            {
                var p:Process = new Process("Swap Process");
                
                _container.bindSwap(p, i, parallel);
                
                p.exec();
            }
        }
        
        public function push(cls:*, parallel:Boolean = false):void
        {
            var p:Process = new Process("Push Process");
            
            _container.bindPush(p, _createView(cls), parallel);
            
            p.exec();
        }
        
        public function pop(parallel:Boolean = false):void
        {
            if (_container.numChildren == 0)
                return;
            
            var p:Process = new Process("Pop Process");
            
            _container.bindPop(p, parallel);
            
            p.exec();
        }
        
        public function replace(cls:*, parallel:Boolean):void
        {
            var p:Process = new Process("Replace Process");
            
            _container.bindReplace(p, _createView(cls), parallel);
            
            p.exec();
        }
        
        public function _applyConfigure(p:Routine, t:Thread):void
        {
            var v:IView = t.readData("nextViewInstance");
            
            if (ApplicationConfigure.NAVI_VALIDATOR.exec(v.naviConfigure))
                _navigation.applyConfigure(v.naviConfigure);
            
            v.applicableHistory;
            
            p.scceeded();
        }
    }
}