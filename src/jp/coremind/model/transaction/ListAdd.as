package jp.coremind.model.transaction
{
    public class ListAdd extends TransactionLog implements ITransactionLog
    {
        /**
         *　toData(setToDataメソッドの呼び出し)必須.
         * 配列を走査しtoDataと同一参照だったインデックスにfromDataを追加する。
         * 同一参照が見つからない場合、配列末尾に追加する。
         */
        public function ListAdd(fromData:*)
        {
            super(fromData);
        }
        
        public function apply(diff:Diff):void
        {
            var list:Array = diff.editedOrigin as Array;
            var toIndex:int = list.indexOf(toData);
            
            list.splice(toIndex == -1 ? list.length: toIndex, 0, fromData);
        }
    }
}