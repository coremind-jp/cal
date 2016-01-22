package jp.coremind.core
{
    public class IdGenerator
    {
        private static const PREFIX_LAYER:String   = "L";
        private static const PREFIX_VIEW:String    = "V";
        private static const PREFIX_ELEMENT:String = "E";
        private static const PREFIX_PARTS:String   = "P";
        
        private var
            _aliasList:Object,
            _counterList:Object;
        
        public function IdGenerator()
        {
            _aliasList   = {};
            _counterList = {};
        }
        
        public function layerId(alias:String):String
        {
            return _reqestId(PREFIX_LAYER, alias);
        }
        
        public function viewId(alias:String):String
        {
            return _reqestId(PREFIX_VIEW, alias);
        }
        
        public function elementId(alias:String):String
        {
            return _reqestId(PREFIX_ELEMENT, alias);
        }
        
        public function partsId(alias:String):String
        {
            return _reqestId(PREFIX_PARTS, alias);
        }
        
        private function _reqestId(prefix:String, alias:String = null):String
        {
            var id:String = prefix+_requestSuffix(prefix);
            
            _aliasList[id] = alias;
            
            return id;
        }
        
        private function _requestSuffix(prefix:String):String
        {
            return prefix in _counterList ?
                uint(_counterList[prefix] += 1).toString(36):
                     _counterList[prefix]  = 0;
        }
        
        public function toAlias(id:String):String
        {
            var result:Array = [];
            
            id.split(".").forEach(function(fragment:String, i:int, arr:Array):void {
                result.push(fragment in _aliasList ? _aliasList[id]: id);
            });
            
            return result.join(".");
        }
    }
}