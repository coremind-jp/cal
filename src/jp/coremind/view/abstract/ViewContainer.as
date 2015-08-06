package jp.coremind.view.abstract
{
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.control.ILayerControl;
    
    public class ViewContainer implements ILayerControl
    {
        private var _container:IViewContainer;
        
        public function ViewContainer(source:IViewContainer)
        {
            _container = source;
            _container.name = "ViewContainer.RootLayer";
        }
        
        public function get numChildren():int
        {
            return _container.numChildren;
        }
        
        public function getViewIndexByClass(cls:Class):int
        {
            for (var i:int = _container.numChildren - 1; 0 <= i; i--) 
                if (Object(_container.getViewAt(i)).constructor === cls)
                    return i;
            return -1;
        }
        
        public function bindPush(p:Process, next:IView, parallel:Boolean = false):void
        {
            var prev:IView = _getActiveView();
            
            if (prev) p.pushThread(_createFocusOutThread(prev), false, parallel);
                      p.pushThread(_createPushThread(next),     false, parallel);
        }
        
        public function bindPop(p:Process, parallel:Boolean = false):void
        {
            var prev:IView = _container.getViewAt(_container.numChildren - 1);
            var next:IView = _container.getViewAt(_container.numChildren - 2);
            
                      p.pushThread(_createFocusOutThread(prev, true), false, parallel);
            if (next) p.pushThread(_createFocusInThread(next,  true), false, parallel);
        }
        
        public function bindSwap(p:Process, i:int, parallel:Boolean = false):void
        {
            var prev:IView = _container.getViewAt(_container.numChildren - 1);
            var next:IView = _container.getViewAt(i);
            
                      p.pushThread(_createFocusOutThread(prev, false), false, parallel);
            if (next) p.pushThread(_createFocusInThread(next,   true), false, parallel);
        }
        
        public function bindReset(p:Process, cls:*, parallel:Boolean = false):void
        {
            _bindStackClearThread(p, parallel);
            p.pushThread(_createPushThread(cls), false, parallel);
        }
        
        public function bindReplace(p:Process, v:IView, parallel:Boolean = false):void
        {
            var prev:IView = _container.getViewAt(_container.numChildren - 1);
            
            p.pushThread(_createFocusOutThread(prev, true), false, parallel);
            p.pushThread(_createPushThread(v),              false, parallel);
        }
        
        protected function _getActiveView():IView
        {
            var i:int = _container.numChildren;
            return i > 0 ? _container.getViewAt(i - 1) as IView: null;
        }
        
        protected function _getPreventView():IView
        {
            var i:int = _container.numChildren;
            return i > 1 ? _container.getViewAt(i - 2) as IView: null;
        }
        
        protected function _bindStackClearThread(p:Process, parallel:Boolean):Process
        {
            var i:int = _container.numChildren - 1;
            
            if (0 < i)
                p.pushThread(_createFocusOutThread(_container.getViewAt(i), true), false, parallel);
            
            for (i -= 1; 0 <= i; i--) 
                p.pushThread(_createPopThread(_container.getViewAt(i)), false, parallel);
            
            return p;
        }
        
        protected function _createPushThread(v:IView):Thread
        {
            return new Thread("Push Thread " + v.name)
                .pushRoutine(v.initialize)
                .pushRoutine(v.addTransition(_container, v));
        }
        
        protected function _createFocusInThread(v:IView, andSwapIndex:Boolean = false):Thread
        {
            return andSwapIndex ?
                new Thread("Focus In/Swap Index Thread " + v.name)
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        _container.removeView(v);
                        _container.addView(v);
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
        
        protected function _createFocusOutThread(v:IView, andPop:Boolean = false):Thread
        {
            return andPop ?
                new Thread("Focus Out/Pop Thread " + v.name)
                    .pushRoutine(v.focusOutPreProcess)
                    .pushRoutine(v.focusOutTransition(_container, v))
                    .pushRoutine(v.focusOutPostProcess)
                    .pushRoutine(v.removeTransition(_container, v))
                    .pushRoutine(v.destroy):
                new Thread("Focus Out Thread " + v.name)
                    .pushRoutine(v.focusOutPreProcess)
                    .pushRoutine(v.focusOutTransition(_container, v))
                    .pushRoutine(v.focusOutPostProcess);
        }
        
        protected function _createPopThread(v:IView):Thread
        {
            return new Thread("Pop Thread " + v.name)
                .pushRoutine(v.removeTransition(_container, v))
                .pushRoutine(v.destroy);
        }
    }
}