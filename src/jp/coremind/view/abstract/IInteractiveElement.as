package jp.coremind.view.abstract
{
    public interface IInteractiveElement
    {
        /**
         * このオブジェクトがステータス上、マウスやポインター操作を受け付けるかを示す値を返す.
         * touchableの値とリンクしているわけでは無いことを留意。
         * このオブジェクトではtouchableがtrueだとしてもprotectedメソッド(_onXXX系ハンドラ)への呼び出しは発生しない。
         * 有効・無効を切り替えるにはenableメソッド、disableメソッドを利用する。
         */
        function isEnable():Boolean;
        
        /**
         * インタラクションの有効・無効を切り替える.
         */
        function toggleEnable():void;
        
        /**
         * このオブジェクトがステータス上でマウスやポインター操作を受け付けるようにする.
         * protectedメソッド(_onXXX系ハンドラ)への呼び出しを行うようになる。
         * このオブジェクトを継承するクラスインスタンスではこのメソッドでインタラクションのon/offを行う。
         */
        function enable():void;
        
        /**
         * このオブジェクトがステータス上でマウスやポインター操作を受け付けるようにしない.
         * このメソッドを呼び出すとフレームワークからのタッチイベントは受け取るもののその後処理するprotectedメソッド(_onXXX系ハンドラ)への呼び出しは行わなくなる。
         * このオブジェクトを継承するクラスインスタンスではこのメソッドでインタラクションのon/offを行う。
         */
        function disable():void;
    }
}