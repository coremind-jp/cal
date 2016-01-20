package jp.coremind.storage.transaction
{
    public class DiffHashInfo
    {
        private var _edited:Vector.<String>;
        
        public function DiffHashInfo()
        {
            _edited = new <String>[];
        }
        
        /**
         * 元データに追加, 削除, 更新を行ったキー一覧を返す.
         */
        public function get edited():Vector.<String> { return _edited; }
    }
}