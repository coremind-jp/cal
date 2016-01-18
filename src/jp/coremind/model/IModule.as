package jp.coremind.model
{
    import jp.coremind.utility.IDispatcher;

    public interface IModule extends IDispatcher
    {
        /** モデルデータを更新する. */
        function update(...params):void;
    }
}