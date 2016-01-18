package jp.coremind.utility.helper
{
    import flash.utils.ByteArray;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    
    import avmplus.getQualifiedClassName;
    
    import jp.coremind.utility.Log;

    public class HelperContainer
    {
        private static const _EMPTY_FUNCTION:Function = new Function();
        
        private var
            _loop:LoopHelper,
            _hash:HashHelper,
            _event:EventHelper,
            _array:ArrayHelper,
            _string:StringHelper;
            
        public function HelperContainer()
        {
            _loop  = new LoopHelper();
            _hash  = new HashHelper();
            _array = new ArrayHelper();
            _event = new EventHelper();
            _string = new StringHelper();
        }
        
        public function get emptyFunction():Function { return _EMPTY_FUNCTION; }
        public function get loop():LoopHelper     { return _loop; }
        public function get hash():HashHelper     { return _hash; }
        public function get array():ArrayHelper   { return _array; }
        public function get event():EventHelper   { return _event; }
        public function get string():StringHelper { return _string; }
        
        /**
         * 引数oがprimitive(String|int|Number|Boolean)型かを示す値を返す.
         * @params  o   任意データ
         * @returns primitive型の場合true, それ以外の場合false
         */
        public function isPrimitive(o:*):Boolean
        {
            var t:String = typeof o;
            return t === "string" || t === "number" || t === "boolean";
        }
        
        /**
         * 引数oが参照型かを示す値を返す.
         * @params  o   任意データ
         * @returns 参照型の場合true, それ以外の場合false
         */
        public function isReference(o:*):Boolean
        {
            return !isPrimitive(o);
        }
        
        /**
         * 引数oがハッシュ配列かを示す値を返す.
         * @params  o   任意データ
         * @returns ハッシュ配列の場合true, それ以外の場合false
         */
        public function isHash(o:*):Boolean
        {
            return typeof o === "object";
        }
        
        public function isArray(o:*):Boolean
        {
            return o is Array;
        }
        
        /**
         * 引数oをバイナリレベルで複製する.
         * @params  o   複製対象データ
         * @retuns  複製データ
         */
        public function clone(o:*):*
        {
            var _binary:ByteArray = new ByteArray();
            _binary.writeObject(o);
            _binary.position = 0;
            return _binary.readObject();
        }
        
        public function getClassByName(className:String, notifyError:Boolean = true):Class
        {
            var _class:Class;
            
            try {
                Log.info("request class", className);
                _class = getDefinitionByName(className) as Class;
            }
            catch (e:ReferenceError)
            {
                if (notifyError) Log.warning(e, className);
                else Log.info(e);
            }
            
            return _class;
        }
        
        public function getClassByInstance(instance:*):Class
        {
            if (instance === null || instance === undefined)
                return null;
            
            return (instance as Object).constructor;
        }
        
        public function isImplements(tagetClass:Class, interfaceClass:Class):Boolean
        {
            for each (var xml:XML in describeType(tagetClass).factory.implementsInterface)
                if (xml.@type == getQualifiedClassName(interfaceClass)) return true;
            return false;
        }
        
        public function bind(f:Function, ...rest):Function
        {
            return function():* { return apply(f, rest); }
        }
        
        CAL::DEBUG
        public function call(f:Function, ...rest):*
        {
            return f.apply(null, rest);
        }
        
        CAL::RELEASE
        public function call(f:Function, ...rest):*
        {
            try {
                return f.apply(null, rest);
            } catch(e:Error) {
                Log.error("anonymouse function error. message("+e.message+")");
                return null;
            }
        }
        
        public function bindByList(f:Function, args:Array):Function
        {
            return function():* { return apply(f, args); }
        }
        
        CAL::DEBUG
        public function apply(f:Function, args:Array):*
        {
            if (!(f is Function))
            {
                Log.error("f paramater is not Function dump auguments", arguments);
                return null;
            }
            
            return f.apply(null, args);
        }
        
        CAL::RELEASE
        public function apply(f:Function, args:Array):*
        {
            if (!(f is Function))
            {
                Log.error("f paramater is not Function dump auguments", arguments);
                return null;
            }
            
            try {
                return f.apply(null, args);
            } catch(e:Error) {
                Log.error("dump auguments", arguments, "\nanonymouse function error. message("+e.message+")");
                return null;
            }
        }
    }
}