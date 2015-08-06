package jp.coremind.view.layout
{
    import flash.utils.Dictionary;

    public class ElementSize
    {
        private static const _INDEX_LIST:Dictionary = new Dictionary(true);
        private static const _SIZE_LIST:Vector.<Number> = new <Number>[];
        
        public static function registry(klass:Class, width:Number, height:Number):void
        {
            if (klass in _INDEX_LIST)
            {
                var i:int = _INDEX_LIST[klass];
                
                _SIZE_LIST[i]   = width;
                _SIZE_LIST[i+1] = height;
            }
            else
            {
                _INDEX_LIST[klass] = _SIZE_LIST.length;
                _SIZE_LIST.push(width, height);
            }
        }
        
        public static function getWidth(klass:Class, defaultValue:Number):Number
        {
            return klass in _INDEX_LIST ? _SIZE_LIST[_INDEX_LIST[klass]]: defaultValue;
        }
        
        public static function getHeight(klass:Class, defaultValue:Number):Number
        {
            return klass in _INDEX_LIST ? _SIZE_LIST[_INDEX_LIST[klass]+1]: defaultValue;
        }
    }
}