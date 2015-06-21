package jp.coremind.resource
{
    import flash.utils.ByteArray;
    
    import jp.coremind.utility.helper.StringHelper;

    public class CSVContent extends TextContent
    {
        public function CSVContent()
        {
            super();
        }
        
        override public function get fileExtention():String
        {
            return "csv";
        }
        
        override public function extract(f:Function, binary:ByteArray):void
        {
            $.call(f, _parseCSV(_toUtf8(binary)));
        }
        
        override public function createFailedContent():*
        {
            return [];
        }
        
        /*
        * CSVからデータを生成する
        * CSVの1行目を列名として、fieldKeysで指定したキー名にします
        * //行の0列をidとしてデータオブジェクトを生成します
        */
        private function _parseCSV(str:String):Array
        {
            var _result:Array = [];
            var _lines:Array = str.split(StringHelper.LF);
            var _keys:Array = _lines.shift().split(',');
            
            while (_lines.length > 0)
            {
                var _fields:Array = _lines.shift().split(',');
                var _record:Object = {};
                
                _keys.forEach(function(key:String, i:int, arr:Array):void {
                    _record[key] = _fields[i];
                });
                
                _result.push(_record);
            }
            
            return _result;
        }
    }
}