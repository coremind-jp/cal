package jp.coremind.view.interaction
{
    public class StatefulElementInteraction
    {
        protected var
            _name:String;
        
        public function StatefulElementInteraction(applyTargetName:String)
        {
            _name = applyTargetName;
        }
        
        public function get applyTargetName():String
        {
            return null;
        }
        
        public function getRuntimeValue(parent:*, params:Array):*
        {
            params = params.slice();
            return parent[params.shift()].apply(null, params);
        }
    }
}