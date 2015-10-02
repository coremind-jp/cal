package jp.coremind.configure
{
    import jp.coremind.view.builder.IDisplayObjectBuilder;

    public interface IElementBluePrint
    {
        /**
         * nameに対応するナビゲーションオブジェクトの一覧を取得する.
         * このメソッドはViewクラスが生成された際に呼び出される。
         * nameに一致するナビゲーションオブジェクトが存在しない場合は空の配列を返す。
         */
        function createNavigationList(name:String):Array;
        
        /**
         * elementClassに対応するコンテンツパーツオブジェクトの一覧を取得する.
         * elementClassと一致するコンテンツパーツオブジェクトが存在しない場合は空の配列を返す。
         */
        function createPartsListByClass(cls:Class):Array;
        
        function createPartsListByName(name:String):Array;
        
        /**
         * nameが指定するコンテンツパーツオブジェクトのbuilderオブジェクトを取得する.
         * builderオブジェクトが存在しない場合はErrorを送出する。
         */
        function createBuilder(name:String):IDisplayObjectBuilder;
    }
}