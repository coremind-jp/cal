package jp.coremind.utility.validation
{
    import jp.coremind.utility.Log;

    public class BooleanValidation
    {
        /**
         * notNull  falseの場合, null or undefinedのみ許容する. falseの場合文字列のみ許容する. 未指定の場合falseと定義される.
         */
        private var _define:Object;
        
        public function BooleanValidation(define:Object)
        {
            _define = define || {};
            
            if (!("notNull" in _define)) $.hash.write(_define, "notNull", false);
        }
        
        private function get notNull():Boolean { return $.hash.read(_define, "notNull") as Boolean; }
        
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
            
            if (!(value is Boolean))
            {
                Log.warning(value, " is not Boolean.");
                return false;
            }
            else
                return true;
        }
    }
}