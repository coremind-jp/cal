package jp.coremind.configure
{
    public interface IApplicationConfigure
    {
        /**
         * アプリケーション起動時にStarlingステージ上で生成するViewクラス、またはViewの名称(String)
         */
        function get initialStarlingView():*
        
        /**
         * アプリケーション起動時にFlashステージ上で生成するViewクラス、またはViewの名称(String)
         */
        function get initialFlashView():*
        
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
         * アプリケーションのルートレイヤー構造設定を返す.
         */
        function get viewLayer():ViewLayerConfigure;
        
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
         * Application.initializeメソッドへ渡すinitialViewがスプラッシュ画面かを示す値を返す.
         */
        function get enabledSplash():Boolean;
    }
}