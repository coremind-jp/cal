package jp.coremind.event
{
    import starling.events.Event;
    
    public class ElementEvent extends Event
    {
        public static const UPDATE_SIZE:String = "updateElementSize";
        
        public function ElementEvent(type:String, bubbles:Boolean=false, data:Object=null)
        {
            super(type, bubbles, data);
        }
    }
}