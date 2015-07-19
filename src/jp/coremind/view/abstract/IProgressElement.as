package jp.coremind.view.abstract
{
    public interface IProgressElement
    {
        /**
         * オブジェクトを破棄する.
         */
        function destroy():void;
        
        /**
         * ゲージの状態をpercentageパラメータを元に更新する.
         * @param   percentage  ゲージ長を0-1で指定する
         */
        function update(percentage:Number):void;
    }
}