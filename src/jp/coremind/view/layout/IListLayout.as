package jp.coremind.view.layout
{
    import flash.geom.Rectangle;
    
    import jp.coremind.storage.StorageModelReader;
    import jp.coremind.view.abstract.IElement;

    /**
     * 抽象レイアウトインターフェース.
     */
    public interface IListLayout
    {
        /** 破棄する. */
        function destroy(withReference:Boolean = false):void;
        
        /** 初期化する. */
        function initialize(reader:StorageModelReader):void;
        
        /**
         * パラメータにマッチするIElementオブジェクトを要求する.
         * @param   modelData   StorageModelReaderから取得した任意データ
         * @param   index       この表示オブジェクトを保持するコンテナ内のオーダーインデックス
         * @param   length      この表示オブジェクトを保持するコンテナ内の子総数
         */
        function requestElement(actualParentWidth:int, actualParentHeight:int, modelData:*, index:int = -1, length:int = -1):IElement;
        
        /** modelDataパラメータにマッチするIElementオブジェクトを未使用(再使用可)状態にする. */
        function requestRecycle(modelData:*):void;
        
        /** modelDataパラメータにマッチするIElementオブジェクトが存在するかを示す値を返す. */
        function hasCache(modelData:*):Boolean;
        
        /** このレイアウトのX座標のスクロールサイズを取得する. */
        function getScrollSizeX(actualParentWidth:Number):Number
        
        /** このレイアウトのY座標のスクロールサイズを取得する. */
        function getScrollSizeY(actualParentHeight:Number):Number
        
        /**
         * パラメータを元にレイアウト(表示オブジェクトの座標、サイズ)を計算する.
         * @param   actualParentWidth       親表示オブジェクトの横幅
         * @param   actualParentHeight      親表示オブジェクトの高さ
         * @param   index                   データ配列インデックス
         * @param   length                  データ配列長
         */
        function calcElementRect(actualParentWidth:int, actualParentHeight:int, index:int, length:int = 0):Rectangle;
        
        /**
         * パラメータを元にレイアウトの領域を計算する.
         * ※戻り値Recatngleのx, yは常に0
         * @param   actualParentWidth       親表示オブジェクトの横幅
         * @param   actualParentHeight      親表示オブジェクトの高さ
         * @param   length                  データ配列長
         */
        function calcTotalRect(actualParentWidth:int, actualParentHeight:int, length:int = 0):Rectangle;
        
        function getTweenRoutineByAddedStage(modelData:*):Function;
        
        function getTweenRoutineByMoved(modelData:*):Function;
        
        function getTweenRoutineByRemovedStage(modelData:*):Function;
    }
}