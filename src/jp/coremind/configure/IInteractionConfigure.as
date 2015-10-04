package jp.coremind.configure
{
    import jp.coremind.view.interaction.IElementInteraction;
    import jp.coremind.view.interaction.StatefulElementInteraction;

    public interface IInteractionConfigure
    {
        function getInteraction(interactionName:String):IElementInteraction;
        function getStatefulElementInteraction(tag:String):StatefulElementInteraction
    }
}