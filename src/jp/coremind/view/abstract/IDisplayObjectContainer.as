package jp.coremind.view.abstract
{
    public interface IDisplayObjectContainer extends IDisplayObject
    {
        /**
         * オブジェクトの子がマウスまたはユーザー入力デバイスに対応しているかどうかを判断します。
         */
        function get numChildren():int;
        
        /**
         * この DisplayObjectContainer インスタンスに子 DisplayObject インスタンスを追加します。
         */
        function addDisplay(child:IDisplayObject):IDisplayObject;
        
        /**
         * この DisplayObjectContainer インスタンスに子 DisplayObject インスタンスを追加します。
         */
        function addDisplayAt(child:IDisplayObject, index:int):IDisplayObject;
        
        /**
         * 指定された表示オブジェクトが、DisplayObjectContainer インスタンスの子であるか、インスタンス自体であるかを指定します。
         */
        function containsDisplay(child:IDisplayObject):Boolean;
        
        /**
         * 指定のインデックス位置にある子表示オブジェクトインスタンスを返します。
         */
        function getDisplayAt(index:int):IDisplayObject;
        
        /**
         * 指定された名前に一致する子表示オブジェクトを返します。
         */
        function getDisplayByName(name:String):IDisplayObject;
        
        /**
         * 子 DisplayObject インスタンスのインデックス位置を返します。
         */
        function getDisplayIndex(child:IDisplayObject):int;
        
        /**
         * cls インスタンスのインデックス位置を返します。
         */
        function getDisplayIndexByClass(cls:Class):int;
        
        /**
         * この DisplayObjectContainer インスタンスに子 DisplayObject インスタンスを追加します。
         */
        function removeDisplay(child:IDisplayObject, dispose:Boolean = false):IDisplayObject;
        
        /**
         * DisplayObjectContainer の子リストの指定された index 位置から子 DisplayObject を削除します。
         */
        function removeDisplayAt(index:int, dispose:Boolean = false):IDisplayObject;
        
        /**
         * DisplayObjectContainer インスタンスの子リストから、すべての child DisplayObject インスタンスを削除します。
         */
        function removeDisplays(beginIndex:int = 0, endIndex:int = 0x7fffffff, dispose:Boolean = false):void;
        
        /**
         * 表示オブジェクトコンテナの既存の子の位置を変更します。
         */
        function setDisplayIndex(child:IDisplayObject, index:int):void;
        
        /**
         * 指定された 2 つの子オブジェクトの z 順序（重ね順）を入れ替えます。
         */
        function swapDisplays(child1:IDisplayObject, child2:IDisplayObject):void;
    }
}