package jp.coremind.view.interaction
{
    import jp.coremind.view.abstract.IElement;

    public interface IElementInteraction
    {
        /** 破棄処理 */
        function destroy():void;
        
        /**
         * インタラクションをビューへ適応する.
         */
        function apply(parent:IElement):void;
        
        /**
         * インタラクションの適応対象を特定するための名前を返す.
         */
        function get applyTargetName():String;
    }
}