package jp.coremind.configure
{
    import jp.coremind.core.StatusModelType;
    import jp.coremind.model.StatusConfigure;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.UpdateRule;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;

    public class StatusModelConfigure
    {
        private static const _CONFIGURE_LIST:Object = {};
        
        public function StatusModelConfigure()
        {
        }
        
        public function initialize():void
        {
            addConfigure(
                StatusModelType.STATEFUL_ELEMENT,
                null);
            
            addConfigure(
                StatusModelType.INTERACTIVE_ELEMENT,
                StatusModelType.STATEFUL_ELEMENT,
                new StatusConfigure(StatusGroup.LOCK, UpdateRule.LESS_THAN_PRIORITY, 100, Status.UNLOCK, true, [Status.UNLOCK])
            );
            
            addConfigure(
                StatusModelType.TOUCH_ELEMENT,
                StatusModelType.INTERACTIVE_ELEMENT,
                new StatusConfigure(StatusGroup.PRESS,   UpdateRule.ALWAYS, 75, Status.UP, false, [Status.CLICK, Status.UP]),
                new StatusConfigure(StatusGroup.RELEASE, UpdateRule.LESS_THAN_PRIORITY, 25, Status.UP, true)
            );
            
            addConfigure(
                StatusModelType.TOUCH_SWITCH,
                StatusModelType.TOUCH_ELEMENT,
                new StatusConfigure(StatusGroup.SELECT, UpdateRule.LESS_THAN_PRIORITY, 50, Status.OFF, true, [Status.OFF])
            );
            
            addConfigure(
                StatusModelType.MOUSE_ELEMENT,
                StatusModelType.INTERACTIVE_ELEMENT,
                new StatusConfigure(StatusGroup.PRESS,   UpdateRule.LESS_THAN_PRIORITY, 75, Status.UP, false, [Status.CLICK, Status.UP]),
                new StatusConfigure(StatusGroup.RELEASE, UpdateRule.ALWAYS, 25, Status.ROLL_OUT, true)
            );
            
            addConfigure(
                StatusModelType.MOUSE_SWITCH,
                StatusModelType.MOUSE_ELEMENT,
                new StatusConfigure(StatusGroup.SELECT, UpdateRule.LESS_THAN_PRIORITY, 50, Status.OFF, true, [Status.OFF])
            );
        }
        
        protected function addConfigure(type:String, baseId:String, ...configure):void
        {
            if (!hasConfigure(type))
                _CONFIGURE_LIST[type] = _extends(baseId, configure);
        }
        
        protected function hasConfigure(type:String):Boolean
        {
            return type in _CONFIGURE_LIST;
        }
        
        public function getConfigure(type:String):Array
        {
                 if (type in _CONFIGURE_LIST) return _CONFIGURE_LIST[type];
            else if (type !== null) Log.warning("undefined StatusModelConfigure from", type);
            
            return [];
        }
        
        /**
         * klassパラメータに指定したconfigureと第二パラメータ以降に指定したconfigureをマージした新しい配列を返す.
         */
        private function _extends(baseType:String, margeList:Array):Array
        {
            var result:Array = getConfigure(baseType).concat(margeList);
            
            result.sortOn("priority", Array.NUMERIC|Array.DESCENDING);
            
            return result;
        }
    }
}