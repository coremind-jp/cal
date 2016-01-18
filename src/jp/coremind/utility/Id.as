package jp.coremind.utility
{
    import flash.utils.Dictionary;

    public class Id
    {
        public static const _FRAGMENT_LIST:Object = {};
        public static const _REFERENCE_COUNTER:Dictionary = new Dictionary(true);
        
        private var _fragments:Vector.<IdFragment>;
        
        public function Id(...primitiveIds)
        {
            _fragments = Vector.<IdFragment>();
        }
        
        public function destroy():void
        {
            while (_fragments.length > 0)
                _destroyFragment(_fragments.pop());
            
            _fragments = null;
        }
        
        public function shift():void
        {
            if (_fragments.length > 0)
            {
                _fragments.fixed = false;
                _fragments.shift();
                _fragments.fixed = true;
            }
        }
        
        public function pop():void
        {
            if (_fragments.length > 0)
            {
                _fragments.fixed = false;
                _fragments.length = _fragments.length - 1;
                _fragments.fixed = true;
            }
        }
        
        public function unshift(...primitiveIds):void
        {
            _fragments.fixed = false;
            
            for (var i:int = primitiveIds.length - 1; 0 <= i; i--) 
                _fragments.unshift(_requestFragment(primitiveIds[i]));
            
            _fragments.fixed = true;
        }
        
        public function push(...primitiveIds):void
        {
            _fragments.fixed = false;
            
            for (var i:int = 0, len:int = primitiveIds.length; i < len; i++) 
                _fragments[_fragments.length] = _requestFragment(primitiveIds[i]);
            
            _fragments.fixed = true;
        }
        
        private function _requestFragment(fragment:String):IdFragment
        {
            if (fragment in _FRAGMENT_LIST)
            {
                _REFERENCE_COUNTER[_FRAGMENT_LIST[fragment]]++;
                return _FRAGMENT_LIST[fragment];
            }
            else
            {
                _REFERENCE_COUNTER[_FRAGMENT_LIST[fragment]] = 0;
                return _FRAGMENT_LIST[fragment] = new IdFragment(fragment);
            }
        }
        
        private function _destroyFragment(idFragment:IdFragment):void
        {
            if (idFragment in _REFERENCE_COUNTER && --_REFERENCE_COUNTER[idFragment] == 0)
                delete _REFERENCE_COUNTER[idFragment];
        }
        
        public function equal(id:Id):Boolean
        {
            for (var i:int = 0, len:int = _fragments.length; i < len; i++) 
                if (_fragments[i] !== id._fragments[i])
                    return false;
            return true;
        }
        
        public function get suffix():*//String or int
        {
            return _fragments.length > 0 ? _fragments[_fragments.length - 1].toString(): null;
        }
        
        public function join(separate:String = "."):String
        {
            var result:String = "";
            
            for (var i:int = 0, len:int = _fragments.length - 1; i < len; i++) 
                result += _fragments[i].primitive + separate;
            result += _fragments[i].primitive;
            
            return result;
        }
    }
}
class IdFragment
{
    private var _fragment:String;
    
    public function IdFragment(fragment:String) { _fragment = fragment; }
    public function get primitive():String { return _fragment; }
}