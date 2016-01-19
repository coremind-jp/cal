package jp.coremind.storage.transaction
{
    public class Diff
    {
        internal var
            _editedOrigin:*,
            _listInfo:DiffListInfo,
            _hashInfo:DiffHashInfo;
        
        public function Diff(
            v:*,
            listInfo:DiffListInfo,
            hashInfo:DiffHashInfo)
        {
            _editedOrigin = v;
            _listInfo = listInfo;
            _hashInfo = hashInfo;
        }
        
        /**
         * 元データにトランザクションに含まれる差分を適応したデータを返す.
         */
        public function get editedOrigin():* { return _editedOrigin; }
        
        public function get listInfo():DiffListInfo { return _listInfo; }
        
        public function get hashInfo():DiffHashInfo { return _hashInfo; }
    }
}