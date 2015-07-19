package jp.coremind.view.abstract
{
    public interface ISwitch extends IInteractiveElement
    {
        /**
         * 選択中かを示す値を返す.
         */
        function isSelected():Boolean;
        
        /**
         * 選択・選択解除を反転させる.
         */
        function toggleSelect():void;
        
        /**
         * 選択状態にする.
         */
        function select():void;
        
        /**
         * 非選択状態にする.
         */
        function deselect():void;
    }
}