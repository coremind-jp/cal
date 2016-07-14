package jp.coremind.configure
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.interaction.IElementInteraction;
    import jp.coremind.view.interaction.StatefulElementInteraction;
    import jp.coremind.view.interaction.StorageInteraction;

    public class InteractionConfigure
    {
        private static const TAG:String = "[InteractionConfigure]";
        //Log.addCustomTag(TAG);
        
        private static const  _EI_CACHE:Object = {};
        private static const _SEI_CACHE:Object = {};
        private static const  _SI_CACHE:Object = {};
        
        public function InteractionConfigure()
        {
        }
        
        protected function createInteraction(interactionName:String, interaction:IElementInteraction):void
        {
            if (!(interactionName in _EI_CACHE))
                _EI_CACHE[interactionName] = interaction;
        }
        
        public function getInteraction(interactionName:String):IElementInteraction
        {
            return _EI_CACHE[interactionName];
        }
        
        protected function addStatefulElementInteraction(interactionName:String, interaction:StatefulElementInteraction):void
        {
            _SEI_CACHE[interactionName] = interaction;
        }
        
        public function getStatefulElementInteraction(interactionName:String):StatefulElementInteraction
        {
            Log.custom(TAG, "getStatefulElementInteraction name:", interactionName);
            return _SEI_CACHE[interactionName];
        }
        
        protected function addStorageInteraction(interactionName:String, interaction:StorageInteraction):void
        {
            _SI_CACHE[interactionName] = interaction;
        }
        
        public function getStorageInteraction(interactionName:String):StorageInteraction
        {
            Log.custom(TAG, "getStorageInteraction name:", interactionName);
            return _SI_CACHE[interactionName];
        }
    }
}