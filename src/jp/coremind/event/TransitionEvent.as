package jp.coremind.event
{
    import flash.events.Event;
    
    import jp.coremind.configure.ITransitionContainer;
    
    public class TransitionEvent extends Event
    {
        /** Viewの切り替え開始時に発生するイベント */
        public static const BEGIN_TRANSITION:String       = "beginTransition";
        
        /** Viewの生成前に発生するイベント */
        public static const VIEW_INITIALIZE_BEFORE:String = "viewInitializeBefore";
        /** Viewの生成後に発生するイベント */
        public static const VIEW_INITIALIZE_AFTER:String  = "viewInitializeAfter";
        
        /** Viewの破棄前に発生するイベント */
        public static const VIEW_DESTROY_BEFORE:String    = "viewDestroyBefore";
        /** Viewの破棄後に発生するイベント */
        public static const VIEW_DESTROY_AFTER:String     = "viewDestroyAfter";
        
        /** Viewの切り替え終了時に発生するイベント */
        public static const END_TRANSITION:String         = "endTransition";
        
        private var
            _layer:String,
            _viewId:String,
            _transition:ITransitionContainer;
        
        public function TransitionEvent(
            type:String,
            layerName:String,
            transition:ITransitionContainer = null,
            targetViewName:String = null,
            bubbles:Boolean=false,
            cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            
            _layer = layerName;
            _viewId  = targetViewName;
            _transition = transition;
        }
        
        public function get layer():String
        {
            return _layer;
        }
        
        public function get viewId():String
        {
            return _viewId;
        }
        
        public function get transitionContainer():ITransitionContainer
        {
            return _transition;
        }
        
        override public function toString():String
        {
            return super.toString()
                + " layer "   + layer
                + " viewId "  + viewId;
        }
    }
}