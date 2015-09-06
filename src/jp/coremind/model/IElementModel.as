package jp.coremind.model
{
    import jp.coremind.utility.IDispatcher;

    public interface IElementModel extends IDispatcher
    {
        /** モデルデータを更新する. */
        function update(...params):void;
    }
}