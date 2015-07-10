package jp.coremind.model.storage
{
    public class StorageType
    {
        /**
         * sqliteを利用したデータ格納インスタンス
         */
        public static const SQ_LITE:String = "sqLite";
        
        /**
         * アプリケーションの起動から終了まで存在し続けるデータ格納インスタンス
         */
        public static const RUNTIME_HASH:String = "runtimeHash";
        
        /**
         * アプリケーションが生成したViewが生成されてから破棄されるまで存在し続けるデータ格納インスタンス
         */
        public static const VIEW_HASH:String = "viewHash";
        
        /**
         * SharedObjectを利用したデータ格納インスタンス
         */
        public static const SHARED:String = "shared";
    }
}