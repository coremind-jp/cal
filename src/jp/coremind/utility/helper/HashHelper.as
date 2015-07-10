package jp.coremind.utility.helper
{
    import jp.coremind.data.HashList;
    import jp.coremind.utility.Log;

    public class HashHelper
    {
        /**
         * 引数pathを元に引数oのハッシュ配列から安全に値を取得する.
         * ハッシュ配列oをルートとしてpが示すパスを辿る過程でパスが存在しない場合undefinedを返す.
         * @params  o       取得対象となるハッシュ配列
         * @params  path    取得した値が格納されているパス(階層は「.」で区切り表現する)
         * @returns pathの値
         */
        public function read(o:Object, path:String):*
        {
            var _hierarchy:Array = path.split(".");
            var _key:String;
            var _val:*;
            
            if (!$.isHash(o))
            {
                Log.warning("arguments is not HashObject. (HashHelper::read)", path, o);
                return undefined;
            }
            
            _key = _hierarchy.shift();
            if (!(_key in o))
            {
                Log.warning("undefined property ["+_key+"]. (HashHelper::read)", path, o);
                return undefined;
            }
            
            _val = o[_key];
            return _hierarchy.length > 0 ? read(_val, _hierarchy.join(".")): _val;
        }
        
        public function keyClone(o:Object):Object
        {
            var _result:Object = {};
            
            for (var p:String in o)
                _result[p] = o[p];
            
            return _result;
        }
        
        public function del(o:Object, path:String):void
        {
            var _hierarchy:Array = path.split(".");
            var _key:String;
            
            if (!$.isHash(o))
                return;
            
            while (_hierarchy.length > 0)
            {
                _key = _hierarchy.shift();
                if (_key in o)
                {
                    if ($.isHash(o[_key]) && _hierarchy.length > 0)
                        o = o[_key];
                    else
                    {
                        o[_key] = null;
                        delete o[_key];
                    }
                }
                else return;
            }
        }
        
        public function write(o:Object, path:String, value:*):void
        {
            var _hierarchy:Array = path.split(".");
            var _key:String;
            var _val:*;
            
            if (!$.isHash(o))
            {
                Log.warning("o is not HashObject. (HashHelper::write)", path, o);
                return;
            }
            
            _key = _hierarchy.shift();
            if (_key in o)
            {
                _hierarchy.length > 0 ?
                    write(o[_key], _hierarchy.join("."), value):
                    Log.error("already defined property ["+_key+"]. (HashHelper::write)", path, o);
            }
            else
            {
                _hierarchy.length > 0 ?
                    write(o[_key] = {}, _hierarchy.join("."), value):
                    o[_key] = value;
            }
        }
        
        public function update(paste:Object, copy:Object):void
        {
            for (var p:String in copy)
                p in paste ?
                    paste[p] = copy[p]:
                    Log.warning("undefined property ["+p+"]. (HashHelper::update)");
        }
        
        public function marge(pasteTo:Object, copyFrom:Object):Object
        {
            for (var p:String in copyFrom) pasteTo[p] = copyFrom[p];
            return pasteTo;
        }
        
        public function asList(o:Object, path:String):HashList
        {
            return new HashList(read(o, path), true);
        }
        
        public function createPropertyList(o:Object):Array
        {
            var _result:Array = [];
            
            for (var key:String in o)
                _result.push(key);
            
            return _result;
        }
        
        public function createUrlParam(o:Object):String
        {
            if (!o) return "";
            
            var _result:Array = [];
            
            for (var key:String in o)
                _result.push(key+"="+o[key]);
            
            return _result.join("&");
        }
    }
}