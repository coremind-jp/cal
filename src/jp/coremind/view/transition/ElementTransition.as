package jp.coremind.view.transition
{
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IElementContainer;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.IObjectTween;
    
    /**
     * IElementインターフェースを実装するクラスインスタンスのelementTransition関数を定義したクラス.
     */
    public class ElementTransition
    {
        private static const TIME:Number = 1.0;
        private static const _SKIP:Function = function(p:Routine, t:Thread):void { p.scceeded(); };
        
        public static function FAST_ADD(container:IElementContainer, element:IElement, fromX:Number = NaN, fromY:Number = NaN, toX:Number = NaN, toY:Number = NaN):Function
        {
            if (!container || !element)
            {
                Log.warning("undefined container or element. container:" + container + " element:" + element);
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                if (!isNaN(fromX)) element.x = fromX;
                if (!isNaN(fromY)) element.y = fromY;
                
                container.addElement(element);
                
                if (isNaN(toX) && isNaN(toY))
                    p.scceeded();
                else
                {
                    var tween:IObjectTween = BetweenAS3.to(element, {
                        x: isNaN(toX) ? element.x: toX,
                        y: isNaN(toY) ? element.y: toY
                    }, TIME);
                    tween.onComplete = p.scceeded;
                    tween.play();
                }
            };
        }
        
        public static function FAST_REMOVE(container:IElementContainer, element:IElement, toX:Number = NaN, toY:Number = NaN):Function
        {
            if (!container || !element)
            {
                Log.warning("undefined container or element. container:" + container + " element:" + element);
                return _SKIP;
            }
            else
            if (!container.containsElement(element))
            {
                Log.warning("not contains element. " + element.name);
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                if (isNaN(toX) && isNaN(toY))
                {
                    container.removeElement(element);
                    p.scceeded();
                }
                else
                {
                    var tween:IObjectTween = BetweenAS3.to(element, {
                        x: isNaN(toX) ? element.x: toX,
                        y: isNaN(toY) ? element.y: toY
                    }, TIME);
                    tween.onComplete = function():void
                    {
                        container.removeElement(element);
                        p.scceeded();
                    };
                    tween.play();
                }
            };
        }
        
        public static function FAST_MOVE(element:IElement, toX:Number, toY:Number, fromX:Number = NaN, fromY:Number = NaN):Function
        {
            if (!element)
            {
                Log.warning("undefined element.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                element.x = toX;
                element.y = toY;
                p.scceeded();
            };
        }
        
        public static function LINER_MOVE(element:IElement, toX:Number, toY:Number, fromX:Number = NaN, fromY:Number = NaN):Function
        {
            if (!element)
            {
                Log.warning("undefined element.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                if (!isNaN(fromX)) element.x = fromX;
                if (!isNaN(fromY)) element.y = fromY;
                
                var tween:IObjectTween = BetweenAS3.to(element, {
                    x: toX,
                    y: toY
                }, TIME);
                tween.onComplete = p.scceeded;
                tween.play();
            };
        }
        
        public static function FAST_VISIBLE(element:IElement):Function
        {
            if (!element)
            {
                Log.warning("undefined element.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                element.visible = true;
                p.scceeded();
            };
        }
        
        public static function FAST_INVISIBLE(element:IElement):Function
        {
            if (!element)
            {
                Log.warning("undefined element.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                element.visible = false;
                p.scceeded();
            };
        }        
        
        public static function SKIP(container:IElementContainer, element:IElement):Function
        {
            return _SKIP
        }
    }
}