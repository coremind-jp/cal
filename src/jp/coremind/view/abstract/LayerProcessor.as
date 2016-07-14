package jp.coremind.view.abstract
{
    import flash.events.IEventDispatcher;
    
    import jp.coremind.asset.Asset;
    import jp.coremind.configure.IViewBluePrint;
    import jp.coremind.core.Application;
    import jp.coremind.controller.Controller;
    import jp.coremind.core.Transition;
    import jp.coremind.event.TransitionEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    
    public class LayerProcessor
    {
        private static const TAG:String = "[LayerProcessor]";
        Log.addCustomTag(TAG);
        
        private static const FOCUS_SKIP:Function = function(r:Routine, t:Thread, v:IView):void { r.scceeded(); };
        
        private var
            _restoreHistory:Vector.<Transition>,
            _dispatcher:IEventDispatcher,
            _container:ICalSprite;
        
        /**
         * ILayoutControlインターフェースを実装したクラスインスタンスに対して
         * 子インスタンス(IView)の追加、削除、置き換えを制御する.
         * @param   source  ILayoutControlインターフェースを実装したクラスインスタンス
         */
        public function LayerProcessor(source:ICalSprite)
        {
            _restoreHistory = new <Transition>[];
            _container = source;
        }
        
        public function set dispatcher(value:IEventDispatcher):void { _dispatcher = value; }
        public function getView(viewId:String):IView { return _container.getDisplayByName(viewId) as IView; }
        
        public function deleteRestoreHistory():void
        {
            _restoreHistory.length = 0;
        }
        
        public function pushEmptyTransition():void
        {
            _restoreHistory.push(null);
        }
        
        public function update(pId:String, commonView:Class, transition:Transition, isRestoreTransition:Boolean = false):void
        {
            if (transition.isRestore())
                _restore(pId, commonView);
            else
            {
                if (!isRestoreTransition)
                    _updateRestoreHistory();
                
                     if (transition.isFilter()) _filter(pId, transition, commonView);
                else if (transition.isAdd())       _add(pId, transition, commonView);
                else if (transition.isRemove()) _remove(pId, transition);
                else if (transition.isFocus()) _pushThreadForRefreshViewFocus(pId, transition);
            }
        }
        
        private function _restore(pId:String, commonView:Class):void
        {
            Log.custom(TAG, "Transition:restore", _container.name);
            
            if (_restoreHistory.length > 0)
            {
                var restoreTransition:Transition = _restoreHistory.pop();
                if (restoreTransition) update(pId, commonView, restoreTransition, true);
            }
        }
        
        private function _updateRestoreHistory():void
        {
            var currentViewIdList:Array = _container.createChildrenNameList();
            
            var focusList:Array = [];
            for (var i:int = 0; i < currentViewIdList.length; i++) 
            {
                var view:IView = getView(currentViewIdList[i]);
                if (view && view.isFocus()) focusList.push(view.name);
            }
            if (focusList.length == 0) focusList = null;
            
            _restoreHistory.push(Transition.filter(currentViewIdList, focusList));
        }
        
        private function _filter(pId:String, transition:Transition, commonView:Class):void
        {
            Log.custom(TAG, "Transition:filter", _container.name);
            
            var requireViewIdList:Array = transition.builderList;
            var removeViewIdList:Array = _createRemoveViewIdList(requireViewIdList);
            for (var i:int = 0; i < removeViewIdList.length; i++) 
                _pushThreadForRemoveView(pId, removeViewIdList[i], transition);
            
            for (i = 0; i < requireViewIdList.length; i++) 
                _pushThreadForAddView(pId, requireViewIdList[i], commonView, transition);
            
            if (transition.focusList) _pushThreadForRefreshViewFocus(pId, transition);
        }
        
        private function _add(pId:String, transition:Transition, commonView:Class):void
        {
            Log.custom(TAG, "Transition:add", _container.name);
            
            var addViewIdList:Array = transition.builderList;
            for (var i:int = 0; i < addViewIdList.length; i++) 
                _pushThreadForAddView(pId, addViewIdList[i], commonView, transition);
            
            if (transition.focusList) _pushThreadForRefreshViewFocus(pId, transition);
        }
        
        private function _remove(pId:String, transition:Transition):void
        {
            Log.custom(TAG, "Transition:remove", _container.name);
            
            var removeViewIdList:Array = transition.builderList;
            for (var i:int = 0; i < removeViewIdList.length; i++) 
                _pushThreadForRemoveView(pId, removeViewIdList[i], transition);
            
            if (transition.focusList) _pushThreadForRefreshViewFocus(pId, transition);
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
        
        private function _pushThreadForRemoveView(pId:String, viewId:String, transition:Transition):void
        {
            var removeView:IView = getView(viewId);
            if (removeView)
                Application.sync.pushThread(pId, _createThreadForRemoveView(removeView), false, transition.parallel);
        }
        
        private function _pushThreadForAddView(pId:String, viewId:String, commonView:Class, transition:Transition):void
        {
            if (getView(viewId)) return;
            
            Asset.allocate(pId, Application.configure.asset.getAllocateIdList(viewId));
            Application.sync.pushThread(pId, _createThreadForAddView(viewId, transition, commonView), false, transition.parallel);
        }
        
        private function _pushThreadForRefreshViewFocus(pId:String, transition:Transition):void
        {
            Application.sync.pushThread(pId, new Thread("Refresh ViewFocus").pushRoutine(function(r:Routine, t:Thread):void
            {
                if (_container.numChildren == 0)
                {
                    r.scceeded("update focus.");
                    return;
                }
                
                Log.custom(TAG, "Transition:focus", _container.name);
                var focusSubProcess:Process = new Process(pId + "[FocusSubProcess]");
                for (var i:int = 0; i < _container.numChildren; i++) 
                {
                    var  view:IView = _container.getDisplayAt(i) as IView;
                    if (!view) continue;
                    
                    var focusRequest:Boolean = transition.focusList.indexOf(view.name) != -1;
                    if (focusRequest && !view.isFocus())
                        focusSubProcess.pushThread(_createThreadForFocusIn(view), false, true);
                    else
                    if (!focusRequest && view.isFocus()) 
                        focusSubProcess.pushThread(_createThreadForFocusOut(view), false, true);
                }
                focusSubProcess.exec(function(p:Process):void { r.scceeded("update focus.") });
            }), true, true);
        }
        
        private function _createThreadForAddView(viewId:String, transition:Transition, commonView:Class):Thread
        {
            var result:Thread = new Thread("AddView " + viewId);
            var bluePrint:IViewBluePrint = Application.configure.viewBluePrint;
            var tweenRoutine:Function = bluePrint.getTweenRoutineByAddedStage(viewId);
            
            return result
                .pushRoutine(_createRoutineForEventDispatch(TransitionEvent.VIEW_INITIALIZE_BEFORE, viewId))
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    var v:IView = bluePrint.createBuilder(viewId).build(viewId, commonView);
                    
                    r.writeData(viewId, _container.addDisplay(v));
                    
                    v.initializeProcess(r, t);
                })
                .pushRoutine(tweenRoutine is Function ?
                    function(r:Routine, t:Thread):void { tweenRoutine(r, t, _container.parentDisplay, t.readData(viewId)); }:
                    Routine.SKIP)
                .pushRoutine(Controller.notifyAddedView, [viewId])
                .pushRoutine(_createRoutineForEventDispatch(TransitionEvent.VIEW_INITIALIZE_AFTER, viewId));
        }
        
        private function _createThreadForRemoveView(v:IView):Thread
        {
            var result:Thread = new Thread("RemoveView " + v.name);
            var bluePrint:IViewBluePrint = Application.configure.viewBluePrint;
            var tweenRoutine:Function = bluePrint.getTweenRoutineByRemovedStage(v.name);
            
            return result
                .pushRoutine(_createRoutineForEventDispatch(TransitionEvent.VIEW_DESTROY_BEFORE, v.name))
                .pushRoutine(Controller.notifyRemovedView, [v.name])
                .pushRoutine(tweenRoutine is Function ?
                    function(r:Routine, t:Thread):void { tweenRoutine(r, t, _container.parentDisplay, v); }:
                    Routine.SKIP)
                .pushRoutine(v.destroyProcess)
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    Asset.dispose(v.name);
                    r.scceeded("disposed Asset");
                })
                .pushRoutine(_createRoutineForEventDispatch(TransitionEvent.VIEW_DESTROY_AFTER, v.name));
        }
        
        private function _createThreadForFocusIn(v:IView, andSwapIndex:Boolean = false):Thread
        {
            var bluePrint:IViewBluePrint = Application.configure.viewBluePrint;
            var tweenRoutine:Function = bluePrint.getTweenRoutineByFocusIn(v.name);
            
            return new Thread("FocusIn " + v.name)
                .pushRoutine(v.focusInPreProcess)
                .pushRoutine(tweenRoutine ? tweenRoutine: FOCUS_SKIP, [v])
                .pushRoutine(v.focusInPostProcess);
        }
        
        private function _createThreadForFocusOut(v:IView):Thread
        {
            var bluePrint:IViewBluePrint = Application.configure.viewBluePrint;
            var tweenRoutine:Function = bluePrint.getTweenRoutineByFocusOut(v.name);
            
            return new Thread("FocusOut " + v.name)
                .pushRoutine(v.focusOutPreProcess)
                .pushRoutine(tweenRoutine ? tweenRoutine: FOCUS_SKIP, [v])
                .pushRoutine(v.focusOutPostProcess);
        }
        
        private function _createRoutineForEventDispatch(type:String, viewId:String):Function
        {
            return function(r:Routine, t:Thread):void
            {
                if (_dispatcher) _dispatcher.dispatchEvent(new TransitionEvent(type, _container.name, null, viewId));
                r.scceeded("dispatch ApplicationGlobalEvent [" + type + "]");
            };
        }
    }
}