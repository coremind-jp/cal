package jp.coremind.view.abstract
{
    import flash.events.IEventDispatcher;
    
    import jp.coremind.asset.Asset;
    import jp.coremind.configure.IViewBluePrint;
    import jp.coremind.configure.ViewConfigure;
    import jp.coremind.configure.ViewInsertType;
    import jp.coremind.control.Controller;
    import jp.coremind.control.SyncProcessController;
    import jp.coremind.core.Application;
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
            _restoreViewConfigure:ViewConfigure,
            _dispatcher:IEventDispatcher,
            _container:ICalSprite;
        
        /**
         * ILayoutControlインターフェースを実装したクラスインスタンスに対して
         * 子インスタンス(IView)の追加、削除、置き換えを制御する.
         * @param   source  ILayoutControlインターフェースを実装したクラスインスタンス
         */
        public function LayerProcessor(source:ICalSprite)
        {
            _container = source;
        }
        
        public function get source():ICalSprite { return _container; }
        
        public function set dispatcher(value:IEventDispatcher):void { _dispatcher = value; }
        
        public function updateView(pId:String, configure:ViewConfigure, commonView:Class):void
        {
            if (configure.insertType == ViewInsertType.RESTORE)
            {
                configure = _restoreViewConfigure;
                if (configure === null) return;
            }
            else _createRestoreViewConfigure();
            
            switch (configure.insertType)
            {
                case ViewInsertType.FILTER:                _filter(pId, configure, commonView); break;
                case ViewInsertType.REQUEST_ADD:       _requestAdd(pId, configure, commonView); break;
                case ViewInsertType.REQUEST_REMOVE: _requestRemove(pId, configure); break;
            }
            
            if (configure.focusList) _pushThreadForRefreshViewFocus(pId, configure);
        }
        
        private function _createRestoreViewConfigure():void
        {
            var currentViewIdList:Array = _container.createChildrenNameList();
            
            var focusList:Array = [];
            for (var i:int = 0; i < currentViewIdList.length; i++) 
            {
                var view:IView = _container.getDisplayByName(currentViewIdList[i]) as IView;
                if (view && view.isFocus()) focusList.push(view.name);
            }
            if (focusList.length == 0) focusList = null;
            
            _restoreViewConfigure = new ViewConfigure(ViewInsertType.FILTER, currentViewIdList, focusList);
        }
        
        private function _filter(pId:String, configure:ViewConfigure, commonView:Class):void
        {
            Log.custom(TAG, "ViewInsertType: FILTER");
            
            var requireViewIdList:Array = configure.builderList;
            var removeViewIdList:Array = _createRemoveViewIdList(requireViewIdList);
            for (var i:int = 0; i < removeViewIdList.length; i++) 
                _pushThreadForRemoveView(pId, removeViewIdList[i], configure);
            
            for (i = 0; i < requireViewIdList.length; i++) 
                _pushThreadForAddView(pId, requireViewIdList[i], commonView, configure);
        }
        
        private function _requestAdd(pId:String, configure:ViewConfigure, commonView:Class):void
        {
            Log.custom(TAG, "ViewInsertType: REQUEST_ADD");
            
            var addViewIdList:Array = configure.builderList;
            for (var i:int = 0; i < addViewIdList.length; i++) 
                _pushThreadForAddView(pId, addViewIdList[i], commonView, configure);
        }
        
        private function _requestRemove(pId:String, configure:ViewConfigure):void
        {
            Log.custom(TAG, "ViewInsertType: REQUEST_REMOVE");
            
            var removeViewIdList:Array = configure.builderList;
            for (var i:int = 0; i < removeViewIdList.length; i++) 
                _pushThreadForRemoveView(pId, removeViewIdList[i], configure);
        }
        
        private function _createRemoveViewIdList(requireViewIdList:Array):Array
        {
            var result:Array = _container.createChildrenNameList();
            
            for (var i:int = 0; i < requireViewIdList.length; i++) 
            {
                var requireViewId:String = requireViewIdList[i];
                var n:int = result.indexOf(requireViewId);
                if (n != -1) result.splice(n, 1);
            }
            
            return result;
        }
        
        private function _pushThreadForRemoveView(pId:String, viewId:String, configure:ViewConfigure):void
        {
            var removeView:IView = _container.getDisplayByName(viewId) as IView;
            if (removeView) sync.pushThread(pId, _createRemoveViewThread(removeView), false, configure.parallel);
        }
        
        private function _pushThreadForAddView(pId:String, viewId:String, commonView:Class, configure:ViewConfigure):void
        {
            if (_container.getDisplayByName(viewId)) return;
            
            Asset.allocate(pId, Application.configure.asset.getAllocateIdList(viewId));
            sync.pushThread(pId, _createAddViewThread(viewId, configure, commonView), false, configure.parallel);
        }
        
        private function _pushThreadForRefreshViewFocus(pId:String, configure:ViewConfigure):void
        {
            sync.pushThread(pId, new Thread("Refresh ViewFocus").pushRoutine(function(r:Routine, t:Thread):void
            {
                if (_container.numChildren == 0)
                {
                    r.scceeded();
                    return;
                }
                
                var focusProcessId:String = pId + "focus";
                for (var i:int = 0; i < _container.numChildren; i++) 
                {
                    var  view:IView = _container.getDisplayAt(i) as IView;
                    if (!view) continue;
                    
                    var focusRequest:Boolean = configure.focusList.indexOf(view.name) != -1;
                    if (focusRequest && !view.isFocus())
                        sync.pushThread(focusProcessId, _createFocusInThread(view), false, configure.parallel);
                    else
                    if (!focusRequest && view.isFocus()) 
                        sync.pushThread(focusProcessId, _createFocusOutThread(view), false, configure.parallel);
                }
                sync.run(focusProcessId, function(p:Process):void { r.scceeded() });
                
            }), true, true);
        }
        
        private function _setup(pId:String, prev:String, next:String):void
        {
            sync.pushThread(pId, new Thread("dispatch ViewTransitionEvent").pushRoutine(
                _dispatchRoutine(ViewTransitionEvent.BEGIN_TRANSITION, null, prev, next)
            ), false, false);
        }
        
        private function _exec(pId:String, prev:String, next:String):void
        {
            //complete handler
            sync.run(pId, function(p:Process):void
            {
                _dispatchEvent(ViewTransitionEvent.END_TRANSITION, null, prev, next);
            });
        }
        
        private function _dispatchRoutine(type:String, target:String = null, prev:String = null, next:String = null):Function
        {
            return function(r:Routine, t:Thread):void { _dispatchEvent(type, target, prev, next); r.scceeded(); };
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
        
        private function get sync():SyncProcessController
        {
            return Controller.getInstance(Controller).syncProcess;
        }
        
        private function _createAddViewThread(viewId:String, configure:ViewConfigure, commonView:Class):Thread
        {
            return new Thread("AddView " + viewId)
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_INITIALIZE_BEFORE, viewId))
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    var bluePrint:IViewBluePrint = Application.configure.viewBluePrint;
                    var view:IView = bluePrint.createBuilder(viewId).build(viewId, commonView);
                    
                    r.writeData("view", view);
                    
                    view.initializeProcess(r, t);
                })
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_INITIALIZE_AFTER, viewId))
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    (t.readData("view") as IView).addTransition(_container, t.readData("view"))(r, t);
                });
        }
        
        private function _createRemoveViewThread(v:IView):Thread
        {
            return new Thread("RemoveView " + v.name)
                .pushRoutine(v.removeTransition(_container, v))
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_DESTROY_BEFORE, v.name))
                .pushRoutine(v.destroyProcess)
                .pushRoutine(_dispatchRoutine(ViewTransitionEvent.VIEW_DESTROY_AFTER, v.name));
        }
        
        private function _createFocusInThread(v:IView, andSwapIndex:Boolean = false):Thread
        {
            return new Thread("FocusIn " + v.name)
                .pushRoutine(v.focusInPreProcess)
                .pushRoutine(v.focusInTransition(_container, v))
                .pushRoutine(v.focusInPostProcess);
        }
        
        private function _createFocusOutThread(v:IView):Thread
        {
            return new Thread("FocusOut " + v.name)
                .pushRoutine(v.focusOutPreProcess)
                .pushRoutine(v.focusOutTransition(_container, v))
                .pushRoutine(v.focusOutPostProcess);
        }
    }
}