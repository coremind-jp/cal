package jp.coremind.model
{
    import jp.coremind.view.abstract.IElement;

    public class ElementModelId
    {
        private var _id:*;
        
        public function ElementModelId(element:IElement)
        {
            _id = $.getClassByInstance(element);
        }
        
        public function destroy():void
        {
            _id = null;
        }
        
        public function equal(expect:*):Boolean
        {
            return _id === expect;
        }
    }
}