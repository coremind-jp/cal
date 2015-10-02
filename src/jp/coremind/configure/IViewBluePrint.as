package jp.coremind.configure
{
    public interface IViewBluePrint
    {
        /**
         * viewに対応するコンテンツオブジェクトの一覧を取得する.
         * このメソッドはViewを継承したクラスが生成された際に呼び出される。
         * viewに一致するコンテンツオブジェクトが存在しない場合は空の配列を返す。
         */
        function createContentListByUniqueView(view:Class):Array;
        
        /**
         * nameに対応するコンテンツオブジェクトの一覧を取得する.
         * このメソッドはViewクラスが生成された際に呼び出される。
         * nameに一致するコンテンツオブジェクトが存在しない場合は空の配列を返す。
         */
        function createContentListByCommonView(name:String):Array;
        
        function getControllerClass(viewName:String):Class
    }
}