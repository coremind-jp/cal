package jp.coremind.utility
{
    public interface IDispatcher
    {
        /** リスナーを追加する. */
        function addListener(listener:Function, priority:int = 0):void;
        
        /** リスナー(listener)が登録されているかを示す値を返す. */
        function hasListener(listener:Function):Boolean;
        
        /** リスナーを削除する. */
        function removeListener(listener:Function):void;
        
        /** 全てのリスナーを削除する. */
        function removeListeners():void;
        
        /** リスナーに通知する. */
        function dispatch(...params):void;
        
        /** 破棄処理 */
        function destroy():void;
    }
}