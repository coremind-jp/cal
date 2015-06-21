package jp.coremind.utility.validation
{
    import jp.coremind.utility.Log;

    public class StringValidation implements IValidation
    {
        /**
         * notNull  falseの場合, null or undefinedのみ許容する. falseの場合文字列のみ許容する. 未指定の場合falseと定義される.
         * length   この値以下の文字数のみ許容する. -1の場合文字数制限をしない. 未指定の場合-1と定義される.
         * rule     この正規表現にマッチするもののみ許容する. 
         */
        private var _define:Object;
        
        public function StringValidation(define:Object)
        {
            _define = define || {};
            
            if (!("notNull" in _define)) $.hash.write(_define, "notNull", false);
            if (!("length"  in _define)) $.hash.write(_define, "length", -1);
            if (!("rule"    in _define)) $.hash.write(_define, "rule", null);
        }
        
        private function get notNull():Boolean { return $.hash.read(_define, "notNull") as Boolean; }
        private function get length():int      { return $.hash.read(_define, "length") as int; }
        private function get rule():RegExp     { return $.hash.read(_define, "rule") as RegExp; }
        
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
            
            if (!(value is String))
            {
                Log.warning(value, " is not String.");
                return false;
            }
            
            var _str:String = value;
            if (-1　< length && length < _str.length)
            {
                Log.warning("number of characters over. " + value);
                return false;
            }
            
            if (!rule)
                return true;
            
            var _matchResult:Array = _str.match(rule);
            if (!_matchResult || _matchResult.length == 0)
            {
                Log.warning("miss match rule. regexp = " + rule.source + " value = " + value);
                return false;
            }
            else
                return true;
        }
    }
}