package jp.coremind.view.interaction
{
    public class ElementInteraction
    {
        protected var _name:String;
        
        public function ElementInteraction(applyTargetName:String)
        {
            _name = applyTargetName;
        }
        
        public function get applyTargetName():String
        {
            return _name;
        }
        
        public function getRuntimeValue(parent:*, params:Array):*
        {
            params = params.slice();
            return parent[params.shift()].apply(null, params);
        }
    }
}