package jp.coremind.core
{
    import jp.coremind.event.ElementInfo;
    import jp.coremind.utility.data.NumberTracker;

    public interface IDragDropControl
    {
        /**
         * ドラッグを開始するかを判定する際に呼び出される.
         * @params  info  ドラッグしようとしている表示オブジェクトのElementInfo
         */
        function dragFiltering(info:ElementInfo):Boolean;
        
        /**
         * ドラッグを開始するかを判定する際に呼び出される.
         * @params  info  ドロップ先表示オブジェクトのElementInfo
         */
        function dropFiltering(info:ElementInfo):Boolean;
        
        /**
         * ドラッグを開始する直前に呼び出される.
         * @param   dragInfo    ドラッグ対象のElementInfo
         * @param   overlapInfo ドロップ位置のElementInfo. 定義されたどのドロップ領域とも重なっていない場合null
         * @param   clonedInfo  ドラッグ対象の複製(ドラッグに使われる)ElementのElementInfo
         * @param   isInitialDropArea   ドラッグ開始時にドラッグ対象が配置されていた領域かを示す値を返す.
         */
        function onDragBegin(dragInfo:ElementInfo, overlapInfo:ElementInfo, clonedInfo:ElementInfo, isInitialDropArea:Boolean):void;
        
        /**
         * ドロップ時に都度呼び出される.
         */
        function onDrag(x:NumberTracker, y:NumberTracker):void;
        
        /**
         * ドラッグ中にドロップ可能領域に接触した際に呼ばれる.
         * @param   dragInfo    ドラッグ対象のElementInfo
         * @param   overlapInfo ドロップ位置のElementInfo. 定義されたどのドロップ領域とも重なっていない場合null
         * @param   clonedInfo  ドラッグ対象の複製(ドラッグに使われる)ElementのElementInfo
         * @param   isInitialDropArea   ドラッグ開始時にドラッグ対象が配置されていた領域かを示す値を返す.
         */
        function onRollover(dragInfo:ElementInfo, overlapInfo:ElementInfo, clonedInfo:ElementInfo, isInitialDropArea:Boolean):void;
        
        /**
         * ドラッグ中にドロップ可能領域から離れた際に呼ばれる.
         * @param   dragInfo    ドラッグ対象のElementInfo
         * @param   overlapInfo ドロップ位置のElementInfo. 定義されたどのドロップ領域とも重なっていない場合null
         * @param   clonedInfo  ドラッグ対象の複製(ドラッグに使われる)ElementのElementInfo
         * @param   isInitialDropArea   ドラッグ開始時にドラッグ対象が配置されていた領域かを示す値を返す.
         */
        function onRollout(dragInfo:ElementInfo, overlapInfo:ElementInfo, clonedInfo:ElementInfo, isInitialDropArea:Boolean):void;
        
        /**
         * ドラッグが終了した時に呼び出される.
         * @param   dragInfo    ドラッグ対象のElementInfo
         * @param   overlapInfo ドロップ位置のElementInfo. 定義されたどのドロップ領域とも重なっていない場合null
         * @param   clonedInfo  ドラッグ対象の複製(ドラッグに使われる)ElementのElementInfo
         * @param   isInitialDropArea   ドラッグ開始時にドラッグ対象が配置されていた領域かを示す値を返す.
         */
        function onDrop(dragInfo:ElementInfo, overlapInfo:ElementInfo, clonedInfo:ElementInfo, isInitialDropArea:Boolean):void;
    }
}