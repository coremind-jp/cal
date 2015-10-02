package jp.coremind.view.abstract
{
    public interface ICalSprite extends IDisplayObjectContainer
    {
        /**
         * このオブジェクトを破棄する.
         */
        function destroy(withReference:Boolean = false):void;
        
        /**
         * ポインターデバイスがこの表示オブジェクトへの入力を有効にする抽象メソッド.
         */
        function enablePointerDeviceControl():void
        
        /**
         * ポインターデバイスがこの表示オブジェクトへの入力を無効にする抽象メソッド.
         */
        function disablePointerDeviceControl():void
        
        /**
         * このオブジェクトが画面に追加される際に再生するTransitionTween生成関数を取得する.
         * このメソッドが返す関数はRoutineクラスに準拠した形で定義する必要がある。
         */
        function get addTransition():Function
        
        /**
         * このオブジェクトが画面内を移動する際に再生するTransitionTween生成関数を取得する.
         * このメソッドが返す関数はRoutineクラスに準拠した形で定義する必要がある。
         */
        function get mvoeTransition():Function
        
        /**
         * このオブジェクトが画面から取り除かれる際に再生するTransitionTween生成関数を取得する.
         * このメソッドが返す関数はRoutineクラスに準拠した形で定義する必要がある。
         */
        function get removeTransition():Function
        
        /**
         * このオブジェクトが画面に表示される際に再生するTransitionTween生成関数を取得する.
         * このメソッドが返す関数はRoutineクラスに準拠した形で定義する必要がある。
         */
        function get visibleTransition():Function
        
        /**
         * このオブジェクトが画面に非表示される際に再生するTransitionTween生成関数を取得する.
         * このメソッドが返す関数はRoutineクラスに準拠した形で定義する必要がある。
         */
        function get invisibleTransition():Function
    }
}