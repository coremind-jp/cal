package jp.coremind.view.parts
{
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;

    public interface IStatefulElementResource
    {
        /** 破棄処理 */
        function destroy():void;
        
        /**
         * このリソースをparentへ即座に適応する.
         */
        function apply(parent:IElement):void;
        
        /**
         * このリソースの適応にThreadが必要かを示す値を返す.
         * この戻り値がtrueの場合、createThread, parallelThread, asyncThreadの実装が必須になる。
         */
        function isThreadType():Boolean;
        
        /**
         * このリソースの適応時にThreadが生成されるかを示す値を返す.
         * このリソースがThreadクラスを利用した非同期処理を含んでいる場合(isThreadTypeメソッドがtrueの時)に呼び出される。
         */
        function createThread(parent:IElement):Thread;
        
        /**
         * このリソースの適応対象を特定するための名前を返す.
         */
        function get applyTargetName():String;
        
        /**
         * このリソースの適応に生成されるThreadがProcess内部で並列で呼び出されるかを示す値を返す.
         * このリソースがThreadクラスを利用した非同期処理を含んでいる場合(isThreadTypeメソッドがtrueの時)に呼び出される。
         */
        function get parallelThread():Boolean;
        
        /**
         * このリソースの適応に生成されるThreadがProcess内部で非同期に呼び出されるかを示す値を返す.
         * このリソースがThreadクラスを利用した非同期処理を含んでいる場合(isThreadTypeメソッドがtrueの時)に呼び出される。
         */
        function get asyncThread():Boolean;
    }
}