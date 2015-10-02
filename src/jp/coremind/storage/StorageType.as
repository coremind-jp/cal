package jp.coremind.storage
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
        
        /**
         * Elementが保持する状態データ格納インスタンス
         */
        public static const ELEMENT:String = "element";
    }
}