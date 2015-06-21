package jp.coremind.utility.validation
{
    import jp.coremind.utility.Log;
    
    public class NumberValidation implements IValidation
    {
        /**
         * notNull  falseの場合, null or undefinedのみ許容する. trueの場合、数値のみ許容する. 未指定の場合falseと定義される.
         * rule     このルールにマッチするもののみ許容する. 文字列として定義する. 定義可能文字は「.-~|0123456789」. .:小数点, -:負の値, ~:の左辺最小値, 右辺最大値の範囲を示す. |:はorを意味する.
         */
        private var _define:Object;
        
        public function NumberValidation(define:Object)
        {
            _define = define || {};
            
            if (!("notNull" in _define)) $.hash.write(_define, "notNull", false);
            if (!("rule"    in _define)) $.hash.write(_define, "rule", null);
        }
        
        private function get notNull():Boolean { return $.hash.read(_define, "notNull") as Boolean; }
        private function get rule():String     { return $.hash.read(_define, "rule") as String; }
        
        public function exec(value:*):Boolean
        {
            if (value === null || value === undefined)
            {
                if (notNull)
                {
                    Log.warning("value is null (or undefined).");
                    return false;
                }
                else
                    return true;
            }
            
            if (!(value is int) && !(value is Number))
            {
                Log.warning(value, " is not int (or Number).");
                return false;
            }
            
            if (!rule)
                return true;
            
            var _ruleList:Array = rule.split("|");
            for (var i:int = 0; i < _ruleList.length; i++) 
            {
                var _rangeRule:Array = _ruleList[i].split("~");
                if (_rangeRule.length == 2)
                {
                    var _min:Number = _rangeRule[0];
                    var _max:Number = _rangeRule[1];
                    if (_min <= value && value <= _max)
                        return true;
                }
                else
                if (Number(_rangeRule[0]) == value)
                    return true;
            }
            
            Log.warning("miss match rule. define = " + rule + " value = " + value);
            return false;
        }
    }
}