package jp.coremind.core
{
    public class Transition
    {
        private static const NONE:int           = 0;
        private static const FILTER:int         = 1;
        private static const REQUEST_ADD:int    = 2;
        private static const REQUEST_REMOVE:int = 3;
        private static const RESTORE:int        = 4;
        
        public static function restore():Transition
        {
            var result:Transition = new Transition();
            
            result._type = RESTORE;
            
            return result;
        }
        
        public static function filter(builderList:Array, focusList:Array = null, parallel:Boolean = false):Transition
        {
            var result:Transition = new Transition();
            
            result._type = FILTER;
            result._builderList = builderList || [];
            result._focusList = focusList;
            result._parallel = parallel;
            
            return result;
        }
        
        public static function add(builderList:Array, focusList:Array = null, parallel:Boolean = false):Transition
        {
            var result:Transition = new Transition();
            
            result._type = REQUEST_ADD;
            result._builderList = builderList;
            result._focusList = focusList;
            result._parallel = parallel;
            
            return result;
        }
        
        public static function remove(builderList:Array, focusList:Array = null, parallel:Boolean = false):Transition
        {
            var result:Transition = new Transition();
            
            result._type = REQUEST_REMOVE;
            result._builderList = builderList;
            result._focusList = focusList;
            result._parallel = parallel;
            
            return result;
        }
        
        public static function removeAll(parallel:Boolean = false):Transition
        {
            var result:Transition = new Transition();
            
            result._type = FILTER;
            result._builderList = [];
            result._focusList = null;
            result._parallel = parallel;
            
            return result;
        }
        
        public static function focus(focusList:Array, parallel:Boolean = false):Transition
        {
            var result:Transition = new Transition();
            
            result._type = NONE;
            result._focusList = focusList;
            result._parallel = parallel;
            
            return result;
        }
        
        private var
            _builderList:Array,
            _focusList:Array,
            _type:int,
            _parallel:Boolean;
        
        public function Transition() {}
        
        public function isFilter():Boolean
        {
            return _type === FILTER;
        }
        
        public function isRestore():Boolean
        {
            return _type === RESTORE;
        }
        
        public function isFocus():Boolean
        {
            return _type === NONE;
        }
        
        public function isAdd():Boolean
        {
            return _type === REQUEST_ADD;
        }
        
        public function isRemove():Boolean
        {
            return _type === REQUEST_REMOVE;
        }
        
        public function get builderList():Array
        {
            return _builderList;
        }
        
        public function get focusList():Array
        {
            return _focusList;
        }
        
        public function get parallel():Boolean
        {
            return _parallel;
        }
    }
}