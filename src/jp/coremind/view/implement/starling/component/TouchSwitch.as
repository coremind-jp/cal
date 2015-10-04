package jp.coremind.view.implement.starling.component
{
    import jp.coremind.core.StatusModelType;
    import jp.coremind.model.module.StatusGroup;
    import jp.coremind.model.module.StatusModel;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.TouchElement;

    /**
     * TouchElementクラスにスイッチ機能を加えたクラス.
     */
    public class TouchSwitch extends TouchElement
    {
        public function TouchSwitch(tapRange:Number=5, backgroundBuilder:IBackgroundBuilder = null)
        {
            super(tapRange, backgroundBuilder);
        }
        
        override protected function get statusModelType():String
        {
            return StatusModelType.TOUCH_SWITCH;
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