package jp.coremind.view.parts
{
    public class StatefulElementResource
    {
        protected var
            _name:String;
        
        public function StatefulElementResource(applyTargetName:String)
        {
            _name = applyTargetName;
        }
        
        public function get applyTargetName():String
        {
            return null;
        }
    }
}