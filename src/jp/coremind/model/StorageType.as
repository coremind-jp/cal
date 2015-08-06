package jp.coremind.model
{
    public class StorageType
    {
        /**
         * sqliteを利用したデータ格納インスタンス
         */
        public static const SQ_LITE:String = "sqLite";
        
        /**
         * ハッシュ配列を利用したデータ格納インスタンス
         */
        public static const HASH:String = "runtimeHash";
        
        /**
         * SharedObjectを利用したデータ格納インスタンス
         */
        public static const SHARED:String = "shared";
    }
}