package jp.coremind.model.module
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    public class StatusModelConfigure
    {
        private static const _LIST:Dictionary = new Dictionary(true);
        
        /**
         * klassパラメータに指定したconfigureと第二パラメータ以降に指定したconfigureをマージした新しい配列を返す.
         */
        public static function marge(klass:Class, ...margeList):Array
        {
            var from:Array = _LIST[klass];
            if (from)
            {
                var result:Array = from.concat(margeList);
                
                result.sortOn("priority", Array.NUMERIC|Array.DESCENDING);
                
                return result;
            }
            else
            {
                Log.error("failed margeConfigureList. undefined StatusModelConfigure from", klass);
                return [];
            }
        }
        
        public static function registry(klass, configure:Array):void
        {
            klass in _LIST ? Log.error("already defined StatusModelConfigure", klass): _LIST[klass] = configure;
        }
        
        public static function request(klass:Class):Array
        {
            return _LIST[klass];
        }
    }
}