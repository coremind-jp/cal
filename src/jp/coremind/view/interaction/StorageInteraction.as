package jp.coremind.view.interaction
{
    import jp.coremind.configure.InteractionConfigure;
    import jp.coremind.core.Application;
    import jp.coremind.view.abstract.IElement;

    public class StorageInteraction
    {
        private var _interactionList:Object;
        
        public function StorageInteraction()
        {
            _interactionList = {};
        }
        
        public function addInteraction(storageKey:*, interactionName:String):StorageInteraction
        {
            _getInteractionNameList(storageKey, _interactionList).push(interactionName);
            return this;
        }
        
        public function apply(parent:IElement, updatedKeyList:Vector.<String>):void
        {
            for (var i:int = 0; i < updatedKeyList.length; i++) 
                _apply(parent, updatedKeyList[i]);
        }
        
        private function _apply(parent:IElement, updatedKey:String):void
        {
            var interactionList:Vector.<String> = _getInteractionNameList(updatedKey, _interactionList);
            var configure:InteractionConfigure = Application.configure.interaction;
            
            for (var i:int, len:int = interactionList.length; i < len; i++)
                configure.getInteraction(interactionList[i]).apply(parent);
        }
        
        private function _getInteractionNameList(key:*, list:Object):Vector.<String>
        {
            if (!(key in list))
                _interactionList[key] = new <String>[];
            
            return _interactionList[key];
        }
    }
}