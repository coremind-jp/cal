package jp.coremind.event
{
    import flash.events.Event;
    
    public class ViewTransitionEvent extends Event
    {
        /** Viewの切り替え開始時に発生するイベント */
        public static const BEGIN_TRANSITION:String       = "beginTransition";
        
        /** 新しいViewの生成前に発生するイベント */
        public static const VIEW_INITIALIZE_BEFORE:String = "viewInitializeBefore";
        /** 新しいViewの生成後に発生するイベント */
        public static const VIEW_INITIALIZE_AFTER:String  = "viewInitializeAfter";
        
        /** 直前のViewの破棄前に発生するイベント */
        public static const VIEW_DESTROY_BEFORE:String    = "viewDestroyBefore";
        /** 直前のViewの破棄後に発生するイベント */
        public static const VIEW_DESTROY_AFTER:String     = "viewDestroyAfter";
        
        /** Viewの切り替え終了時に発生するイベント */
        public static const END_TRANSITION:String         = "endTransition";
        
        private var
            _layer:String,
            _name:String,
            _prev:String,
            _next:String;
        
        public function ViewTransitionEvent(
            type:String,
            layerName:String,
            targetViewName:String = null,
            prevViewName:String = null,
            nextViewName:String = null,
            bubbles:Boolean=false,
            cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            
            _layer = layerName;
            _name  = targetViewName;
            _prev  = prevViewName;
            _next  = nextViewName;
        }
        
        public function get layer():String
        {
            return _layer;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function get prev():String
        {
            return _prev;
        }

        public function get next():String
        {
            return _next;
        }
        
        override public function toString():String
        {
            return super.toString()
                + " layer " + layer
                + " name "  + name
                + " prev "  + prev
                + " next "  + next;
        }
    }
}