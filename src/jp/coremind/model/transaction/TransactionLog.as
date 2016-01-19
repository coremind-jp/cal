package jp.coremind.model.transaction
{
    public class TransactionLog
    {
        private var
            _fromData:*,  //Storageに存在する実データ(操作元)
            _toData:*;    //Storageに存在する実データ(編集先)※継承先の実装次第では利用しない場合もある
        
        public function TransactionLog(fromData:*)
        {
            _fromData = fromData;
        }
        public function get fromData():* { return _fromData; }
        
        
        public function setToData(toData:*):TransactionLog
        {
            _toData = toData;
            return this;
        }
        public function get toData():* { return _toData; }
    }
}