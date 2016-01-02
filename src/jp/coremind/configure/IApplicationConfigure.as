package jp.coremind.configure
{
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.IUrlConverter;

    public interface IApplicationConfigure
    {
        /**
         * アプリケーション内で利用するビュー定義を返す.
         */
        function get viewBluePrint():IViewBluePrint;
        
        /**
         * アプリケーション内で利用するエレメント定義を返す.
         */
        function get elementBluePrint():IElementBluePrint;
        
        /**
         * アプリケーション内で利用するパーツ定義を返す.
         */
        function get partsBluePrint():IPartsBluePrint;
        
        /**
         * アプリケーション内で利用するデータ定義を返す.
         */
        function get storage():IStorageConfigure;
        
        /**
         * アプリケーション内でリソース設定を返す.
         */
        function get asset():IAssetConfigure;
        
        /**
         * StatefulElementで利用するステータス定義を返す.
         */
        function get statusModel():StatusModelConfigure;
        
        /**
         * インタラクション定義を返す.
         */
        function get interaction():InteractionConfigure;
        
        /**
         * アプリケーションのルートレイヤー構造設定を返す.
         */
        function get viewLayer():ViewLayerConfigure;
        
        /**
         * アプリケーションのレイアウトに利用した画面サイズ
         */
        function get appViewPort():Rectangle;
        
        /**
         * 起動する機器の画面サイズ(デバッグ)
         */
        function get useDebugViewPort():Boolean;
        
        /**
         * 起動する機器の画面サイズ(デバッグ)
         */
        function get debugViewPort():Rectangle;
        
        
        function get framerate():int;
        
        /**
         * アプリケーションのアスペクト比(横：縦)
         */
        function get displayAspectRatio():Number;
        
        /**
         * アプリケーションのアスペクト比が基準にしている画面の向き
         * PC基準のため、モバイル機器の場合はScreenOrientationをLandscapeLeft/Rightに
         */
        function get screenOrientaion():int;
        
        /**
         * ローカルファイルを参照する際に利用するURLコンバーター.
         */
        function get urlConverter():IUrlConverter;
    }
}