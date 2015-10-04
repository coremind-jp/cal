package jp.coremind.core
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Expo;
    import org.libspark.betweenas3.tweens.IObjectTween;
    
    /**
     * IDisplayObjectインターフェースを実装するクラスインスタンスのelementTransition関数を定義したクラス.
     */
    public class TransitionTween
    {
        private static const TIME:Number = .2;
        private static const _SKIP:Function = function(p:Routine, t:Thread):void { p.scceeded(); };
        
        public static function FAST_ADD(parent:IDisplayObjectContainer, child:IDisplayObject, fromX:Number = NaN, fromY:Number = NaN, toX:Number = NaN, toY:Number = NaN):Function
        {
            if (!parent || !child)
            {
                Log.warning("undefined parent or child. parent:" + parent + " child:" + child);
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                if (!isNaN(fromX)) child.x = fromX;
                if (!isNaN(fromY)) child.y = fromY;
                
                parent.addDisplay(child);
                
                if (isNaN(toX) && isNaN(toY))
                    p.scceeded();
                else
                {
                    var tween:IObjectTween = BetweenAS3.to(child, {
                        x: isNaN(toX) ? child.x: toX,
                        y: isNaN(toY) ? child.y: toY
                    }, TIME);
                    tween.onComplete = p.scceeded;
                    tween.play();
                }
            };
        }
        
        public static function FAST_REMOVE(parent:IDisplayObjectContainer, child:IDisplayObject, toX:Number = NaN, toY:Number = NaN):Function
        {
            if (!parent || !child)
            {
                Log.warning("undefined parent or child. parent:" + parent + " child:" + child);
                return _SKIP;
            }
            else
            if (!parent.containsDisplay(child))
            {
                Log.warning("not contains child. " + child.name);
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                if (isNaN(toX) && isNaN(toY))
                {
                    parent.removeDisplay(child);
                    p.scceeded();
                }
                else
                {
                    var tween:IObjectTween = BetweenAS3.to(child, {
                        x: isNaN(toX) ? child.x: toX,
                        y: isNaN(toY) ? child.y: toY
                    }, TIME);
                    tween.onComplete = function():void
                    {
                        parent.removeDisplay(child);
                        p.scceeded();
                    };
                    tween.play();
                }
            };
        }
        
        public static function FAST_MOVE(child:IDisplayObject, toX:Number, toY:Number, fromX:Number = NaN, fromY:Number = NaN):Function
        {
            if (!child)
            {
                Log.warning("undefined child.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                child.x = toX;
                child.y = toY;
                p.scceeded();
            };
        }
        
        public static function LINER_MOVE(child:IDisplayObject, toX:Number, toY:Number, fromX:Number = NaN, fromY:Number = NaN):Function
        {
            if (!child)
            {
                Log.warning("undefined child.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                if (!isNaN(fromX)) child.x = fromX;
                if (!isNaN(fromY)) child.y = fromY;
                
                var tween:IObjectTween = BetweenAS3.to(child, {
                    x: toX,
                    y: toY
                }, TIME, Expo.easeOut);
                tween.onComplete = p.scceeded;
                tween.play();
            };
        }
        
        public static function FAST_VISIBLE(child:IDisplayObject):Function
        {
            if (!child)
            {
                Log.warning("undefined child.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                child.visible = true;
                p.scceeded();
            };
        }
        
        public static function FAST_INVISIBLE(child:IDisplayObject):Function
        {
            if (!child)
            {
                Log.warning("undefined child.");
                return _SKIP;
            }
            
            return function(p:Routine, t:Thread):void
            {
                child.visible = false;
                p.scceeded();
            };
        }        
        
        public static function SKIP(parent:IDisplayObjectContainer, child:IDisplayObject):Function
        {
            return _SKIP
        }
    }
}