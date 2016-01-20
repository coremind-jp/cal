package jp.coremind.view.abstract
{
    public interface ICalSprite extends IDisplayObjectContainer
    {
        /**
         * このオブジェクトを破棄する.
         */
        function destroy(withReference:Boolean = false):void;
        
        /**
         * このオブジェクト内に存在する子表示オブジェクトのnameプロパティーリストを生成する.
         */
        function createChildrenNameList():Array;
    }
}