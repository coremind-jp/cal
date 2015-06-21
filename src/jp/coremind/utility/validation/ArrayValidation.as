package jp.coremind.utility.validation
{
    import jp.coremind.utility.Log;
    
    public class ArrayValidation implements IValidation
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
                     context: { type:int, def: { notNull:true, rule:"0~9|15|36" }},
                 }
             }}
         }
         };
         */
        private var _define:Object;
        
        public function ArrayValidation(define:Object)
        {
            _define = define || {};
            
            if (!("notNull" in _define)) $.hash.write(_define, "notNull", false);
            if (!("context" in _define)) $.hash.write(_define, "context", null);
        }
        
        private function get notNull():Boolean { return $.hash.read(_define, "notNull"); }
        private function get context():Array   { return $.hash.read(_define, "context") as Array; }
        
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
            
            var _context:Array = context;
            if (!_context)
                return true;
            
            for (var i:int = 0; i < _context.length; i++) 
                if (!_each(_context[i], value))
                    return false;
            
            return true;
        }
        
        private function _each(context:Object, value:*):Boolean
        {
            switch (context.type)
            {
                case "int"   : case int:
                case "number": case Number: return new NumberValidation(context.def).exec(value);
                case "string": case String: return new StringValidation(context.def).exec(value);
                case "object": case Object: return new HashValidation(context.def).exec(value);
                case "array" : case Array : return new ArrayValidation(context.def).exec(value);
                default : Log.warning("unknown validation type. " + context.type); return false;
            }
        }
    }
}