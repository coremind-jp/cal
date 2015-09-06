package jp.coremind.utility
{
    /**
     * インスタンスの再利用インターフェース
     */
    public interface IRecycle
    {
        /** 破棄する. */
        function destroy(withReference:Boolean = false):void;
        
        /** 状態をリセットし再利用可能にする. */
        function reset():void;
    }
}