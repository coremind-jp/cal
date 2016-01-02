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
        function enablePointerDeviceControl():void;
        
        /**
         * ポインターデバイスがこの表示オブジェクトへの入力を無効にする抽象メソッド.
         */
        function disablePointerDeviceControl():void;
        
        /**
         * このオブジェクト内に存在する子表示オブジェクトのnameプロパティーリストを生成する.
         */
        function createChildrenNameList():Array;
    }
}