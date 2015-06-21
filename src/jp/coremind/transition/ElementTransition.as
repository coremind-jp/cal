package jp.coremind.transition
{
    import jp.coremind.control.Routine;
    import jp.coremind.control.Thread;
    import jp.coremind.utility.Log;
    import jp.coremind.view.IElement;
    import jp.coremind.view.IElementContainer;

    public class ElementTransition
    {
        private static const _SKIP:Function = function(p:Routine, t:Thread):void { p.scceeded(); };
        
        public static function FAST_ADD(container:IElementContainer, element:IElement):Function
        {
            return function(p:Routine, t:Thread):void
            {
                Log.info(container, element);
                if (container && element)
                {
                    container.addElement(element);
                    p.scceeded();
                }
                else p.failed("undefined container or element. container:" + container + " element:" + element);
            }
        }
        
        public static function FAST_REMOVE(container:IElementContainer, element:IElement):Function
        {
            return function(p:Routine, t:Thread):void
            {
                if (container && element)
                {
                    if (container.containsElement(element))
                    {
                        container.removeElement(element);
                        p.scceeded();
                    }
                    else p.failed("not contains element. " + element.name);
                }
                else p.failed("undefined container or element. container:" + container + " element:" + element);
            }
        }
        
        public static function FAST_MOVE(element:IElement, x:Number, y:Number):Function
        {
            return function(p:Routine, t:Thread):void
            {
                if (element)
                {
                    element.x = x;
                    element.y = y;
                }
                else p.failed("undefined element. element:" + element);
            }
        }
        
        public static function SKIP(container:IElementContainer, element:IElement):Function
        {
            return _SKIP
        }
    }
}