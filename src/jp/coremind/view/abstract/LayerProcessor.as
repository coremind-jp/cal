package jp.coremind.view.abstract
{
    import flash.events.IEventDispatcher;
    
    import jp.coremind.asset.Asset;
    import jp.coremind.control.Controller;
    import jp.coremind.event.ViewTransitionEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    
    public class LayerProcessor
    {
        private static const TAG:String = "[LayerProcessor]";
        Log.addCustomTag(TAG);
        
        private static const RESET_PROCESS:String   = "ResetProcess-";
        private static const SWAP_PROCESS:String    = "SwapProcess-";
        private static const PUSH_PROCESS:String    = "PushProcess-";
        private static const POP_PROCESS:String     = "PopProcess-";
        private static const REPLACE_PROCESS:String = "ReplaceProcess-";
        
        private var
            _commonViewClass:Class,
            _dispatcher:IEventDispatcher,
            _container:ICalSprite;
        
        /**
         * ILayoutControlインターフェースを実装したクラスインスタンスに対して
         * 子インスタンス(IView)の追加、削除、置き換えを制御する.
         * @param   source  ILayoutControlインターフェースを実装したクラスインスタンス
         */
        public function LayerProcessor(source:ICalSprite, commonViewClass:Class)
        {
            _container = source;
            _commonViewClass = commonViewClass;
        }
        
        public function get source():ICalSprite { return _container; }
        
        public function set dispatcher(value:IEventDispatcher):void { _dispatcher = value; }
        
        public function push(nextView:*, parallel:Boolean = false, terminateAsyncProcess:Boolean = true):void
        {
            var pId:String = PUSH_PROCESS + _container.name;
            var prev:IView = _getActiveView();
            var next:IView = _createView(nextView);
            var prevName:String = prev ? prev.name: null;
            
            Asset.allocate(pId, next.name);
            
            _setup(pId, terminateAsyncProcess, prevName, next.name);
            if (prev) controller.syncProcess.pushThread(pId, _createFocusOutThread(prev), false, parallel);
                      controller.syncProcess.pushThread(pId, _createPushThread(next),     false, parallel);
            _exec(pId, prevName, next.name);
        }
        
        public function pop(parallel:Boolean = false, terminateAsyncProcess:Boolean = true):void
        {
            if (_container.numChildren == 0) return;
            
            var pId:String = POP_PROCESS + _container.name;
            var prev:IView = _container.getDisplayAt(_container.numChildren - 1) as IView;
            var next:IView = null;
            var nextName:String = null;
            if (_container.numChildren > 1)
            {
                next = _container.getDisplayAt(_container.numChildren - 2) as IView;
                nextName = next.name;
            }
            
            _setup(pId, terminateAsyncProcess, prev.name, nextName);
                      controller.syncProcess.pushThread(pId, _createFocusOutThread(prev, true), false, parallel);
            if (next) controller.syncProcess.pushThread(pId, _createFocusInThread(next,  true), false, parallel);
            _exec(pId, prev.name, nextName);
        }
        
        public function swap(swapView:*, parallel:Boolean = false, terminateAsyncProcess:Boolean = true):void
        {
            var i:int = _getViewIndex(swapView);
            
            if (i == -1)
                push(swapView, parallel, terminateAsyncProcess);
            else
            {
                var pId:String = SWAP_PROCESS + _container.name;
                var prev:IView = _container.getDisplayAt(_container.numChildren - 1) as IView;
                var next:IView = _container.getDisplayAt(i) as IView;
                var nextName:String = next ? next.name: null;
                
                _setup(pId, terminateAsyncProcess, prev.name, nextName);
                          controller.syncProcess.pushThread(pId, _createFocusOutThread(prev, false), false, parallel);
                if (next) controller.syncProcess.pushThread(pId, _createFocusInThread(next,   true), false, parallel);
                _exec(pId, prev.name, nextName);
            }
        }
        
        public function reset(nextView:*, parallel:Boolean = false, terminateAsyncProcess:Boolean = true):void
        {
            var pId:String = RESET_PROCESS + _container.name;
            var next:IView = _createView(nextView);
            
            Asset.allocate(pId, next.name);
            
            _setup(pId, terminateAsyncProcess, null, next.name);
            _bindStackClearThread(pId, parallel);
            controller.syncProcess.pushThread(pId, _createPushThread(next), false, parallel);
            _exec(pId, null, next.name);
        }
        
        public function replace(replaceView:*, parallel:Boolean = false, terminateAsyncProcess:Boolean = true):void
        {
            var pId:String = REPLACE_PROCESS + _container.name;
            var prev:IView = _container.getDisplayAt(_container.numChildren - 1) as IView;
            var next:IView = _createView(replaceView);
            
            Asset.allocate(pId, next.name);
            
            _setup(pId, terminateAsyncProcess, prev.name, next.name);
            controller.syncProcess.pushThread(pId, _createFocusOutThread(prev, true), false, parallel);
            controller.syncProcess.pushThread(pId, _createPushThread(next),           false, parallel);
            _exec(pId, prev.name, next.name);
        }
        
        private function _setup(pId:String, terminateAsyncProcess:Boolean, prev:String, next:String):void
        {
            if (terminateAsyncProcess) controller.asyncProcess.terminateAll();
            
            controller.syncProcess
                .pushThread(pId, new Thread("dispatch ViewTransitionEvent")
                    .pushRoutine(_dispatchRoutine(ViewTransitionEvent.BEGIN_TRANSITION, null, prev, next)
                ), false, false);
        }
        
        private function _exec(pId:String, prev:String, next:String):void
        {
            //complete handler
            controller.syncProcess.exec(pId, function(p:Process):void
            {
                _dispatchEvent(ViewTransitionEvent.END_TRANSITION, null, prev, next);
            });
        }
        
        private function _dispatchRoutine(type:String, target:String = null, prev:String = null, next:String = null):Function
        {
            return function(r:Routine, t:Thread):void
            {
                _dispatchEvent(type, target, prev, next);
                r.scceeded();
            };
        }
        
        private function _dispatchEvent(
            type:String,
            targetViewName:String = null,
            prevViewName:String = null,
            nextViewName:String = null):void
        {
            if (_dispatcher)
            {
                var e:ViewTransitionEvent = new ViewTransitionEvent(type, _container.name, targetViewName, prevViewName, nextViewName);
                Log.custom(TAG, e);
                _dispatcher.dispatchEvent(e);
            }
        }
        
        private function get controller():Controller
        {
            return Controller.getInstance(Controller);
        }
        
        private function _createView(cls:*):IView
        {
            if (cls is IView) return cls;
            if (cls is Class) return new cls();
            if (cls is String)
            {
                if (cls.indexOf("::") == -1)
                {
                    Log.custom(TAG, "use common view. name[", cls, "]");
                    return new _commonViewClass(cls);
                }
                else
                {
                    var c:Class = $.getClassByName(cls);
                    return new c();
                }
            }
            else
            {
                Log.error("LayerProcessor create instance falid. arguments:", cls);
                return null;
            }
        }
        
        private function _getViewIndex(view:*):int
        {
                 if (view is Class)  return _container.getDisplayIndexByClass(view);
            else if (view is String) return view.indexOf("::") == -1 ?
                    _container.getDisplayIndex(_container.getDisplayByName(view)):
                    _container.getDisplayIndexByClass($.getClassByName(view));
            else
            {
                Log.error("LayerProcessor not found index. arguments:", view);
                return null;
            }
        }
        
        private function _getActiveView():IView
        {
            var i:int = _container.numChildren;
            return i > 0 ? _container.getDisplayAt(i - 1) as IView: null;
        }
        
        private function _getPreventView():IView
        {
            var i:int = _container.numChildren;
            return i > 1 ? _container.getDisplayAt(i - 2) as IView: null;
        }
        
        private function _bindStackClearThread(name:String, parallel:Boolean):void
        {
            var i:int = _container.numChildren - 1;
            
            if (0 < i)
                controller.syncProcess.pushThread(name, _createFocusOutThread(_container.getDisplayAt(i) as IView, true), false, parallel);
            
            for (i -= 1; 0 <= i; i--) 
                controller.syncProcess.pushThread(name, _createPopThread(_container.getDisplayAt(i) as IView), false, parallel);
        }
        
        private function _createPushThread(v:IView):Thread
        {
            return new Thread("Push Thread " + v.name)
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_INITIALIZE_BEFORE, v.name))
                .pushRoutine(v.initializeProcess)
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_INITIALIZE_AFTER, v.name))
                .pushRoutine(v.addTransition(_container, v));
        }
        
        private function _createFocusInThread(v:IView, andSwapIndex:Boolean = false):Thread
        {
            return andSwapIndex ?
                new Thread("Focus In/Swap Index Thread " + v.name)
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        _container.setDisplayIndex(v, _container.numChildren-1);
                        r.scceeded();
                    })
                    .pushRoutine(v.focusInPreProcess)
                    .pushRoutine(v.focusInTransition(_container, v))
                    .pushRoutine(v.focusInPostProcess):
                new Thread("Focus In Thread " + v.name)
                    .pushRoutine(v.focusInPreProcess)
                    .pushRoutine(v.focusInTransition(_container, v))
                    .pushRoutine(v.focusInPostProcess);
        }
        
        private function _createFocusOutThread(v:IView, andPop:Boolean = false):Thread
        {
            return andPop ?
                new Thread("Focus Out/Pop Thread " + v.name)
                    .pushRoutine(v.focusOutPreProcess)
                    .pushRoutine(v.focusOutTransition(_container, v))
                    .pushRoutine(v.focusOutPostProcess)
                    .pushRoutine(v.removeTransition(_container, v))
                    .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_DESTROY_BEFORE, v.name))
                    .pushRoutine(v.destroyProcess)
                    .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_DESTROY_AFTER, v.name)):
                new Thread("Focus Out Thread " + v.name)
                    .pushRoutine(v.focusOutPreProcess)
                    .pushRoutine(v.focusOutTransition(_container, v))
                    .pushRoutine(v.focusOutPostProcess);
        }
        
        private function _createPopThread(v:IView):Thread
        {
            return new Thread("Pop Thread " + v.name)
                .pushRoutine(v.removeTransition(_container, v))
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_DESTROY_BEFORE, v.name))
                .pushRoutine(v.destroyProcess)
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_DESTROY_AFTER, v.name));
        }
    }
}