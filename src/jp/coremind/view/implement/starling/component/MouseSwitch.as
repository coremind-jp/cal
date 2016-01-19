package jp.coremind.view.implement.starling.component
{
    import jp.coremind.core.Application;
    import jp.coremind.core.StatusModelType;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModule;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.MouseElement;
    import jp.coremind.view.layout.Layout;
    
    /**
     * MouseElementクラスにスイッチ機能を加えたクラス.
     */
    public class MouseSwitch extends MouseElement
    {
        public function MouseSwitch(layoutCalculator:Layout, backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
        }
        
        override protected function get statusModelType():String
        {
            return StatusModelType.MOUSE_SWITCH;
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            _info.modules.getModule(StatusModule).update(StatusGroup.SELECT, null);
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case StatusGroup.SELECT:
                    switch(status)
                    {
                        case Status.ON:
                            _onSelected();
                            Application.router.notify(_info, group, status);
                            return true;
                            
                        case Status.OFF:
                            _onDeselected();
                            Application.router.notify(_info, group, status);
                            return true;
                    }
            }
            return super._applyStatus(group, status);
        }
        
        override protected function _onClick():void
        {
            var status:StatusModule = _info.modules.getModule(StatusModule) as StatusModule;
            
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