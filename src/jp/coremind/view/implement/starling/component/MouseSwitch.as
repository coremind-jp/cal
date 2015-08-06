package jp.coremind.view.implement.starling.component
{
    import jp.coremind.model.StatusModelConfigure;
    import jp.coremind.model.StatusConfigure;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.UpdateRule;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.implement.starling.MouseElement;
    
    /**
     * MouseElementクラスにスイッチ機能を加えたクラス.
     */
    public class MouseSwitch extends MouseElement
    {
        override protected function get _statusModelConfigureKey():Class { return MouseSwitch }
        
        StatusModelConfigure.registry(
            MouseSwitch,
            StatusModelConfigure.marge(
                MouseElement,
                    new StatusConfigure(StatusGroup.SELECT, UpdateRule.LESS_THAN_PRIORITY, 50, Status.OFF, true, [Status.OFF])
                ));
        
        public function MouseSwitch(tapRange:Number=5)
        {
            super(tapRange);
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            controller.buttonSwitch.refresh(_reader.id);
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case StatusGroup.SELECT:
                    switch(status)
                    {
                        case Status.ON:    _onSelected(); return true;
                        case Status.OFF: _onDeselected(); return true;
                    }
            }
            return super._applyStatus(group, status);
        }
        
        override protected function _onClick():void
        {
            controller.buttonSwitch.toggleSwitch(_reader.id);
            super._onClick();
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_SELECT
         * value : Status.SELECT
         */
        protected function _onSelected():void
        {
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_SELECT
         * value : Status.DESELECT
         */
        protected function _onDeselected():void
        {
        }
    }
}