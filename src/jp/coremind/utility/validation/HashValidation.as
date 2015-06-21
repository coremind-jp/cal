package jp.coremind.utility.validation
{
    import jp.coremind.utility.Log;
    
    public class HashValidation implements IValidation
    {
        /**
         * notNull  falseの場合, null or undefinedのみ許容する. trueの場合、数値のみ許容する. 未指定の場合falseと定義される.
         * context  ハッシュルール定義
         * (ex:
            {
                notNull:true,
                context: {
                    a: { type:int   , req:true, def: { notNull:true, rule:"0~9|15|36" }},
                    b: { type:String, req:true, def: { notNull:false, length:256 }},
                    c: { type:Object, req:true, def: {
                        notNull:true,
                        context: {
                            d: { type:int   , req:true, def: { notNull:true, rule:"0~9|15|36" }},
                            e: { type:String, req:true, def: { notNull:false, length:256 }}
                        }
                    }}
                }
            };
         */
        private var _define:Object;
        
        public function HashValidation(define:Object)
        {
            _define = define || {};
            
            if (!("notNull" in _define)) $.hash.write(_define, "notNull", false);
            if (!("context" in _define)) $.hash.write(_define, "context", null);
        }
        
        private function get notNull():Boolean { return $.hash.read(_define, "notNull"); }
        private function get context():Object  { return $.hash.read(_define, "context"); }
        
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
            
            var _context:Object = context;
            for (var p:String in _context)
                if (!_each(p, _context, value))
                    return false;
            
            return true;
        }
        
        private function _each(key:String, context:Object, value:*):Boolean
        {
            var _contextElement:Object = context[key];
            if (!(key in value))
            {
                if (_contextElement.req)
                {
                    Log.warning("undefined property. " + key);
                    return false;
                }
                else
                    return true;
            }
            
            var v:* = value[key];
            switch (_contextElement.type)
            {
                case int:
                case Number : return new NumberValidation(_contextElement.def).exec(v);
                case String : return new StringValidation(_contextElement.def).exec(v);
                case Object : return new HashValidation(_contextElement.def).exec(v);
                case Array  : return new ArrayValidation(_contextElement.def).exec(v);
                case Boolean: return new BooleanValidation(_contextElement.def).exec(v);
                default :
                    Log.warning("unknown validation type. " + _contextElement.type);
                    return false;
            }
        }
    }
}