package jp.coremind.module
{
    import jp.coremind.utility.IDispatcher;

    public interface IModule extends IDispatcher
    {
        /** モデルデータを更新する. */
        function update(...params):void;
    }
}