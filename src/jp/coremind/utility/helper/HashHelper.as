package jp.coremind.utility.helper
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.HashList;

    public class HashHelper
    {
        /**
         * 引数pathを元に引数oのハッシュ配列から安全に値を取得する.
         * ハッシュ配列oをルートとしてpが示すパスを辿る過程でパスが存在しない場合undefinedを返す.
         * @params  o       取得対象となるハッシュ配列
         * @params  path    取得した値が格納されているパス(階層は「.」で区切り表現する)
         * @returns pathの値
         */
        public function read(o:Object, path:String, warningLog:Boolean = true):*
        {
            return _read(o, path.split("."), warningLog);
        }
        
        private function _read(o:Object, hierarchy:Array, warningLog:Boolean):*
        {
            if (!$.isHash(o))
            {
                if (warningLog) Log.warning("arguments is not HashObject. (HashHelper::read)", hierarchy);
                return undefined;
            }
            
            var _key:String = hierarchy.shift();
            if (!(_key in o))
            {
                if (warningLog) Log.warning("undefined property ["+_key+"]. (HashHelper::read)", hierarchy);
                return undefined;
            }
            
            return hierarchy.length > 0 ? _read(o[_key], hierarchy, warningLog): o[_key];
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
            _write(o, path.split("."), value);
        }
        
        private function _write(o:Object, hierarchy:Array, value:*):void
        {
            var _key:String;
            var _val:*;
            
            if (!$.isHash(o))
            {
                Log.warning("o is not HashObject. (HashHelper::write)", hierarchy, o);
                return;
            }
            
            _key = hierarchy.shift();
            if (_key in o)
                hierarchy.length > 0 ? _write(o[_key], hierarchy, value):
                    Log.error("already defined property ["+_key+"]. (HashHelper::write)", hierarchy);
            else
                hierarchy.length > 0 ? _write(o[_key] = {}, hierarchy, value): o[_key] = value;
        }
        
        public function isDefined(o:Object, path:String):Boolean
        {
            var _hierarchy:Array = path.split(".");
            var _key:String;
            
            while (_hierarchy.length > 0)
            {
                _key = _hierarchy.shift();
                
                if (_key in o) o = o[_key];
                else return false;
            }
            
            return true;
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
        
        public function free(hash_or_dic:*):*
        {
            for (var p:* in hash_or_dic) delete hash_or_dic[p];
            return null;
        }
        
        public function createUrlParam(o:Object):String
        {
            if (!o) return "";
            
            var _result:Array = [];
            
            for (var key:String in o)
                _result.push(key+"="+o[key]);
            
            return _result.join("&");
        }
        
        public function findKey(o:Object, v:*):*
        {
            for (var p:String in o) 
                if (o[p] === v) return p;
            return null;
        }
    }
}