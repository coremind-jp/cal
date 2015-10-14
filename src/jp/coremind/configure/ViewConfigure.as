package jp.coremind.configure
{
    public class ViewConfigure
    {
        private var
            _builderList:Array,
            _focusList:Array,
            _insertType:String,
            _parallel:Boolean;
        
        public function ViewConfigure(
            insertType:String,
            builderList:Array,
            focusList:Array = null,
            parallel:Boolean = false)
        {
            _insertType = insertType;
            _builderList = builderList;
            _focusList = focusList;
            _parallel = parallel;
        }
        
        public function get builderList():Array
        {
            return _builderList;
        }
        
        public function get focusList():Array
        {
            return _focusList;
        }
        
        public function get insertType():String
        {
            return _insertType;
        }
        
        public function get parallel():Boolean
        {
            return _parallel;
        }
    }
}