package jp.coremind.core
{
    public interface IApplicationConfigure
    {
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
         * ディスプレイにコンテンツを表示した際に可変長となる軸
         * VariableDirection定数を設定
         */
        function get variableDirection():int;
        
        /**
         * アプリケーションで生成されるViewの内履歴として残しておき
         */
        function get viewHistory():void;
    }
}