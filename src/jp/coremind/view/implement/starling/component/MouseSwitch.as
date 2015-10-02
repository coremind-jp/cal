package jp.coremind.view.implement.starling.component
{
    import jp.coremind.model.module.StatusConfigure;
    import jp.coremind.model.module.StatusGroup;
    import jp.coremind.model.module.StatusModel;
    import jp.coremind.model.module.StatusModelConfigure;
    import jp.coremind.model.transaction.UpdateRule;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.MouseElement;
    import jp.coremind.view.layout.LayoutCalculator;
    
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
        
        public function MouseSwitch(
            layoutCalculator:LayoutCalculator,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            _elementModel.getModule(StatusModel).update(StatusGroup.SELECT, null);
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
            var status:StatusModel = _elementModel.getModule(StatusModel) as StatusModel;
            
            status.getGroupStatus(StatusGroup.SELECT).equal(Status.ON) ?
                status.update(StatusGroup.SELECT, Status.OFF):
                status.update(StatusGroup.SELECT, Status.ON);
            
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