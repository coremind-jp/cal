package jp.coremind.view.interaction
{
    import jp.coremind.configure.IInteractionConfigure;
    import jp.coremind.core.Application;
    import jp.coremind.view.abstract.IElement;

    public class StatefulElementInteraction
    {
        private static const _INTERACTION_CACHE:Object = {};
        
        private var _interactionList:Object;
        
        public function StatefulElementInteraction()
        {
            _interactionList = {};
        }
        
        public function addInateraction(group:String, status:String, interactionName:String):StatefulElementInteraction
        {
            _getInteractionNameList(group, status).push(interactionName);
            return this;
        }
        
        private function _getInteractionNameList(group:String, status:String):Vector.<String>
        {
            if (!(group in _interactionList))
                _interactionList[group] = {};
            
            if (!(status in _interactionList[group]))
                _interactionList[group][status] = new <String>[];
            
            return _interactionList[group][status];
        }
        
        public function apply(parent:IElement, group:String, status:String):void
        {
            var interactionList:Vector.<String> = _getInteractionNameList(group, status);
            var configure:IInteractionConfigure = Application.configure.interaction;
            
            for (var i:int, len:int = interactionList.length; i < len; i++)
                configure.getInteraction(interactionList[i]).apply(parent);
        }
    }
}