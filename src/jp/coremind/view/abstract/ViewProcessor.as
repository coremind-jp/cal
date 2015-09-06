package jp.coremind.view.abstract
{
    import jp.coremind.control.Controller;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    
    public class ViewProcessor
    {
        public static const RESET_PROCESS:String   = "ResetProcess";
        public static const SWAP_PROCESS:String    = "SwapProcess";
        public static const PUSH_PROCESS:String    = "PushProcess";
        public static const POP_PROCESS:String     = "PopProcess";
        public static const REPLACE_PROCESS:String = "ReplaceProcess";
        
        private var _container:IViewContainer;
        
        /**
         * ILayoutControlインターフェースを実装したクラスインスタンスに対して
         * 子インスタンス(IView)の追加、削除、置き換えを制御する.
         * @param   source  ILayoutControlインターフェースを実装したクラスインスタンス
         */
        public function ViewProcessor(source:IViewContainer)
        {
            _container = source;
        }
        
        public function get controller():Controller
        {
            return Controller.getInstance(Controller);
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
        
        
//------
        public function bindPush(name:String, next:IView, parallel:Boolean = false):void
        {
            var prev:IView = _getActiveView();
            
            controller.asyncProcess.terminateAll();
            if (prev) controller.syncProcess.pushThread(name, _createFocusOutThread(prev), false, parallel);
                      controller.syncProcess.pushThread(name, _createPushThread(next),     false, parallel);
        }
        
        public function bindPop(name:String, parallel:Boolean = false):void
        {
            var prev:IView = _container.getViewAt(_container.numChildren - 1);
            var next:IView = _container.getViewAt(_container.numChildren - 2);
            
            controller.asyncProcess.terminateAll();
                      controller.syncProcess.pushThread(name, _createFocusOutThread(prev, true), false, parallel);
            if (next) controller.syncProcess.pushThread(name, _createFocusInThread(next,  true), false, parallel);
        }
        
        public function bindSwap(name:String, i:int, parallel:Boolean = false):void
        {
            var prev:IView = _container.getViewAt(_container.numChildren - 1);
            var next:IView = _container.getViewAt(i);
            
            controller.asyncProcess.terminateAll();
                      controller.syncProcess.pushThread(name, _createFocusOutThread(prev, false), false, parallel);
            if (next) controller.syncProcess.pushThread(name, _createFocusInThread(next,   true), false, parallel);
        }
        
        public function bindReset(name:String, cls:*, parallel:Boolean = false):void
        {
            _bindStackClearThread(name, parallel);
            
            controller.asyncProcess.terminateAll();
            controller.syncProcess.pushThread(name, _createPushThread(cls), false, parallel);
        }
        
        public function bindReplace(name:String, v:IView, parallel:Boolean = false):void
        {
            var prev:IView = _container.getViewAt(_container.numChildren - 1);
            
            controller.asyncProcess.terminateAll();
            controller.syncProcess.pushThread(name, _createFocusOutThread(prev, true), false, parallel);
            controller.syncProcess.pushThread(name, _createPushThread(v),              false, parallel);
        }
//------
        
        
        
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
        
        protected function _bindStackClearThread(name:String, parallel:Boolean):void
        {
            var i:int = _container.numChildren - 1;
            
            if (0 < i)
                controller.syncProcess.pushThread(name, _createFocusOutThread(_container.getViewAt(i), true), false, parallel);
            
            for (i -= 1; 0 <= i; i--) 
                controller.syncProcess.pushThread(name, _createPopThread(_container.getViewAt(i)), false, parallel);
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