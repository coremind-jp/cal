package jp.coremind.configure
{
    import jp.coremind.view.interaction.IElementInteraction;
    import jp.coremind.view.interaction.StatefulElementInteraction;

    public class InteractionConfigure implements IInteractionConfigure
    {
        private static const  _EI_CACHE:Object = {};
        private static const _SEI_CACHE:Object = {};
        
        public function InteractionConfigure()
        {
        }
        
        protected function createInteraction(interactionName:String, interaction:IElementInteraction):void
        {
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
            return _SEI_CACHE[interactionName];
        }
    }
}