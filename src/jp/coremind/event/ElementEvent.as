package jp.coremind.event
{
    import starling.events.Event;
    
    public class ElementEvent extends Event
    {
        public static const UPDATE_SIZE:String = "updateElementSize";
        public static const UPDATE_CONTAINER_SIZE:String = "updateContainerSize";
        public static const READY:String = "ready";
        
        public function ElementEvent(type:String, bubbles:Boolean=false, data:Object=null)
        {
            super(type, bubbles, data);
        }
    }
}