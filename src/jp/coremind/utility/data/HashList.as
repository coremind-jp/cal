package jp.coremind.utility.data
{
    import jp.coremind.utility.Log;

    public class HashList extends List
    {
        private var _isTmporary:Boolean;
        
        public function HashList(source:Array, temporaryInstance:Boolean = false)
        {
            _isTmporary = temporaryInstance;
            super(source);
        }
        
        public function fetch(path:String):Array
        {
            var _result:Array = [];
            
            for (var i:int = 0, len:int = length; i < len; i++) 
                _result.push($.hash.read(_source[i], path));
            
            if (_isTmporary) destory();
            
            return _result;
        }
        
        public function find(prop:String, value:*):Object
        {
            for (var i:int = 0, len:int = length; i < len; i++) 
            {
                var _element:Object = $.hash.read(_source[i], prop);
                if (_element == value) return _source[i];
            }
            
            if (_isTmporary) destory();
            
            return undefined;
        }
        
        public function findIndex(prop:String, value:*):int
        {
            for (var i:int = 0, len:int = length; i < len; i++) 
                if ($.hash.read(_source[i], prop) == value)
                    return i;
            
            if (_isTmporary) destory();
            
            return -1;
        }
        
        /**
         * リストの全要素の引数pathが示すプロパティーについて引数f関数を実行し、fがtrueを返す要素のみの配列を返す.
         * @params  path    取得した値が格納されているパス(階層は「.」で区切り表現する)
         * @params  f       実行関数
         * @return  fがtrueを返す要素
         * 
         * fは以下のクロージャ関数でなければならない
         * 
         * function (elementValue:*):Boolean {
         *     return true or false;
         * }
         * 
         * (ex: プロパティ「id」が10以上の要素を取り出す場合、
         * var src:Array = [
         *  { id: 10, name: a },
         *  { id:  2, name: b },
         *  { id: 70, name: c }
         * ];
         * 
         * var list:Array = new HashList(src).filter("id", function(v:*):Boolean
         * {
         *     return v >= 10;
         * });
         * 
         * //listの中身は以下のようになっている
         * [
         *  { id: 10, name: a },
         *  { id: 70, name: c }
         * ];
         * 
         * ※基本的な評価関数はListFilterクラスに定義されている。
         */
        public function filter(path:String, f:Function):Array
        {
            var _result:Array = [];
            
            for (var i:int = 0, len:int = length; i < len; i++) 
                if (f($.hash.read(_source[i], path)))
                    _result.push(_source[i]);
            
            if (_isTmporary) destory();
            
            return _result;
        }
        
        public function toString():String
        {
            return Log.toString(_source);
        }
    }
}