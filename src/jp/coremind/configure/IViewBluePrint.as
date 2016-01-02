package jp.coremind.configure
{
    import jp.coremind.view.builder.ViewBuilder;

    public interface IViewBluePrint
    {
        function createBuilder(name:String):ViewBuilder;
        function getTweenRoutineByAddedStage(name:String):Function;
        function getTweenRoutineByRemovedStage(name:String):Function;
        function getTweenRoutineByFocusIn(name:String):Function;
        function getTweenRoutineByFocusOut(name:String):Function;
    }
}