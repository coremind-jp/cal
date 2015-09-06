package jp.coremind.control
{
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.EventDispatcher;
    
    import jp.coremind.utility.process.Process;
    import jp.coremind.view.abstract.INavigationView;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.view.abstract.ViewLayer;
    import jp.coremind.view.abstract.ViewProcessor;
    import jp.coremind.view.implement.flash.NavigationView;
    import jp.coremind.view.implement.flash.RootView;

    public class CpuViewController extends EventDispatcher
    {
        protected var
            _viewProcessorList:Vector.<ViewProcessor>;
        
        private var
            _root:Sprite;
        
        public function CpuViewController()
        {
            _viewProcessorList = new <ViewProcessor>[];
        }
        
        public function disablePointerDevice():void { _root.mouseChildren = _root.mouseEnabled = false; }
        
        public function enablePointerDevice():void  { _root.mouseChildren = _root.mouseEnabled = true; }
        
        public function get controller():Controller { return Controller.getInstance(Controller); }
        
        private function _createView(cls:*):IView
        {
            var c:Class = _getClass(cls);
            return new c();
        }
        
        private function _getClass(cls:*):Class
        {
            return cls is Class ? cls: $.getClassByName(cls);
        }
        
        protected function _getProcessor(layerIndex:int):ViewProcessor
        {
            return _viewProcessorList[layerIndex];
        }
        
        public function get navigation():INavigationView
        {
            return _root.getChildAt(ViewLayer.NAVIGATION) as INavigationView;
        }
        
        public function createRootLayer(stage:Stage, initialView:Class):void
        {
            stage.addChild(_root = new Sprite());
            
            for (var i:int = 0; i < ViewLayer.LENGTH; i++)
                _viewProcessorList[i] = new ViewProcessor(_root.addChild(new RootView()) as RootView);
            
            push(ViewLayer.NAVIGATION, NavigationView);
            if (initialView) push(ViewLayer.CONTENT, initialView);
        }
        
        public function reset(layer:int, cls:*, parallel:Boolean = false):void
        {
            var name:String = ViewProcessor.RESET_PROCESS + layer;
            
            _viewProcessorList[layer].bindReset(name, _createView(cls), parallel);
            
            controller.refreshStorage();
            controller.syncProcess.exec(name, _refreshStorage);
        }
        
        public function swap(layer:int, cls:*, parallel:Boolean = false):void
        {
            var i:int = _viewProcessorList[layer].getViewIndexByClass(_getClass(cls));
            
            if (i == -1)
                push(cls, parallel);
            else
            {
                var name:String = ViewProcessor.SWAP_PROCESS + layer;
                
                _viewProcessorList[layer].bindSwap(name, i, parallel);
                
                controller.refreshStorage();
                controller.syncProcess.exec(name, _refreshStorage);
            }
        }
        
        public function push(layer:int, cls:*, parallel:Boolean = false):void
        {
            var name:String = ViewProcessor.PUSH_PROCESS + layer;
            
            _viewProcessorList[layer].bindPush(name, _createView(cls), parallel);
            
            controller.refreshStorage();
            controller.syncProcess.exec(name, _refreshStorage);
        }
        
        public function pop(layer:int, parallel:Boolean = false):void
        {
            if (_viewProcessorList[layer].numChildren == 0)
                return;
            
            var name:String = ViewProcessor.POP_PROCESS + layer;
            
            _viewProcessorList[layer].bindPop(name, parallel);
            
            controller.syncProcess.exec(name, _refreshStorage);
        }
        
        public function replace(layer:int, cls:*, parallel:Boolean):void
        {
            var name:String = ViewProcessor.REPLACE_PROCESS + layer;
            
            _viewProcessorList[layer].bindReplace(name, _createView(cls), parallel);
            
            controller.syncProcess.exec(name, _refreshStorage);
        }
        
        private function _refreshStorage(p:Process):void
        {
            controller.refreshStorage();
        }
    }
}