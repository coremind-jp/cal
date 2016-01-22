package jp.coremind.core
{
    public class Layer
    {
        /** コンテンツレイヤー */
        public static const CONTENT:String    = Application.idGen.layerId("Content");
        /** ナビゲーションレイヤー */
        public static const NAVIGATION:String = Application.idGen.layerId("Navigation");
        /** ポップアップレイヤー */
        public static const POPUP:String      = Application.idGen.layerId("Popup");
        /** システムレイヤー */
        public static const SYSTEM:String     = Application.idGen.layerId("System");
    }
}