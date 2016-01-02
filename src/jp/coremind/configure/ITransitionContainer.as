package jp.coremind.configure
{
    import jp.coremind.core.Transition;

    public interface ITransitionContainer
    {
        function get name():String;
        function get length():int;
        function get targetStage():String;
        function get deleteRestoreHistory():Boolean;
        function getTransition(layer:String):Transition;
    }
}