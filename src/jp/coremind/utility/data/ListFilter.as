package jp.coremind.utility.data
{
    public class ListFilter
    {
        public static function EQUAL(param:*):Function     { return function(propertyValue:*):Boolean { return propertyValue === param }; }
        public static function UNEQUAL(param:*):Function   { return function(propertyValue:*):Boolean { return propertyValue !== param }; }
        
        public static function SAME(param:*):Function      { return function(propertyValue:*):Boolean { return propertyValue ==  param }; }
        public static function DIFFERENT(param:*):Function { return function(propertyValue:*):Boolean { return propertyValue !=  param }; }
        
        public static function MORE_THAN(param:*):Function { return function(propertyValue:*):Boolean { return propertyValue >  param }; }
        public static function AND_MORE(param:*):Function  { return function(propertyValue:*):Boolean { return propertyValue >= param }; }
        
        public static function LESS_THAN(param:*):Function { return function(propertyValue:*):Boolean { return propertyValue <  param }; }
        public static function AND_LESS(param:*):Function  { return function(propertyValue:*):Boolean { return propertyValue <= param }; }
    }
}