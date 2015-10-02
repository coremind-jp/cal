package jp.coremind.view.interaction
{
    import flash.utils.Dictionary;
    
    import jp.coremind.view.abstract.IElement;

    public class StatefulElementInteractionListener
    {
        private static const _REGISTED:Dictionary = new Dictionary(true);
        public static function isRegisted(klass:Class):Boolean { return klass in _REGISTED; }
        public static function request(klass:Class):StatefulElementInteractionListener
        {
            return klass in _REGISTED ?
                _REGISTED[klass]:
                _REGISTED[klass] = new StatefulElementInteractionListener();
        }
        
        private var _listContainer:Object;
        
        public function StatefulElementInteractionListener()
        {
            _listContainer = {};
        }
        
        public function destroy():void
        {
            for (var key:String in _listContainer)
            {
                var list:Vector.<IStatefulElementInteraction> = _getListenerList(key);
                
                for (var i:int = 0, len:int = list.length; i < len; i++) 
                    list[i].destroy();
                list.length = 0;
                
                _listContainer[key] = null;
                delete _listContainer[key];
            }
        }
        
        public function addResource(group:String, status:String, resource:IStatefulElementInteraction):StatefulElementInteractionListener
        {
            var key:String = group + status;
            _getListenerList(key).push(resource);
            
            return this;
        }
        
        public function apply(group:String, status:String, parent:IElement):void
        {
            var key:String = group + status;
            var list:Vector.<IStatefulElementInteraction> = _getListenerList(key);
            var callExec:Boolean = false;
            
            for (var i:int = 0, len:int = list.length; i < len; i++) 
            {
                var interaction:IStatefulElementInteraction = list[i];
                
                if (interaction.isThreadType())
                {
                    callExec = true;
                    
                    parent.controller.asyncProcess.pushThread(
                        parent.storageId+key,
                        interaction.createThread(parent),
                        interaction.parallelThread,
                        interaction.asyncThread);
                }
                else
                    interaction.apply(parent);
            }
            
            if (callExec) parent.controller.asyncProcess.run(parent.storageId+key);
        }
        
        private function _getListenerList(key:String):Vector.<IStatefulElementInteraction>
        {
            return key in _listContainer ?
                _listContainer[key]:
                _listContainer[key] = new <IStatefulElementInteraction>[];
        }
    }
}