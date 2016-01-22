package jp.coremind.utility.helper
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.HashList;

    public class HashHelper
    {
        public static const TAG:String = "[HashHelper]";
        
        /**
         * 引数pathを元に引数oのハッシュ配列から安全に値を取得する.
         * ハッシュ配列oをルートとしてpが示すパスを辿る過程でパスが存在しない場合undefinedを返す.
         * @params  o       取得対象となるハッシュ配列
         * @params  path    取得した値が格納されているパス(階層は「.」で区切り表現する)
         * @returns pathの値
         */
        public function read(o:Object, path:String, warningLog:Boolean = true):*
        {
            var i:int, len:int, key:String;
            var hierarchy:Array = path.split(".");
            
            if (warningLog)
            {
                for (i = 0, len = hierarchy.length; i < len; i++) 
                {
                    if (!$.isHash(o))
                    {
                        Log.warning(TAG, "read failed. arguments is not HashObject.", hierarchy);
                        return undefined;
                    }
                    
                    key = hierarchy[i];
                    
                    if (!(key in o))
                    {
                        Log.warning(TAG, "read failed. undefined property ["+key+"].", hierarchy);
                        return undefined;
                    }
                    
                    o = o[key];
                }
            }
            else
            {
                for (i = 0, len = hierarchy.length; i < len; i++) 
                {
                    key = hierarchy[i];
                    
                    if (!$.isHash(o) || !(key in o)) return undefined;
                    
                    o = o[key];
                }
            }
            
            return o;
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
            var hierarchy:Array = path.split(".");
            for (var i:int = 0, len:int = hierarchy.length - 1; i < len; i++) 
            {
                if (!$.isHash(o))
                {
                    Log.warning(TAG, "delete failed. arguments is not HashObject.", hierarchy);
                    return;
                }
                
                var key:String = hierarchy[i];
                if (key in o) o = o[key]; else return;
            }
            
            if (o) delete o[hierarchy[i]];
        }
        
        public function write(o:Object, path:String, value:*):void
        {
            var hierarchy:Array = path.split(".");
            for (var i:int = 0, len:int = hierarchy.length - 1; i < len; i++) 
            {
                if (!$.isHash(o))
                {
                    Log.warning(TAG, "write failed. arguments is not HashObject.", hierarchy);
                    return;
                }
                
                var key:String = hierarchy[i];
                o = key in o ? o[key]: o[key] = {};
            }
            
            hierarchy[i] in o ?
                Log.error(TAG, "write failed. already defined property. ["+hierarchy[i]+"].", hierarchy):
                o[hierarchy[i]] = value;
        }
        
        public function isDefined(o:Object, path:String):Boolean
        {
            var hierarchy:Array = path.split(".");
            for (var i:int = 0, len:int = hierarchy.length - 1; i < len; i++) 
            {
                if (!$.isHash(o)) return false;
                
                var key:String = hierarchy[i];
                if (key in o) o = o[key] else return false;
            }
            
            return hierarchy[i] in o;
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