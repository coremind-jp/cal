package jp.coremind.view.implement.starling.component
{
    import jp.coremind.configure.StatusConfigure;
    import jp.coremind.configure.UpdateRule;
    import jp.coremind.utility.MultistageStatus;
    import jp.coremind.utility.Status;
    import jp.coremind.view.abstract.ISwitch;
    import jp.coremind.view.implement.starling.TouchElement;

    /**
     * TouchElementクラスにスイッチ機能を加えたクラス.
     */
    public class TouchSwitch extends TouchElement implements ISwitch
    {
        public static const GROUP_SELECT:String = "groupSelect";
        
        private static const CONFIG_LIST:Array = MultistageStatus.margePriorityList(
            TouchElement.CONFIG_LIST,
                new StatusConfigure(GROUP_SELECT, UpdateRule.LESS_THAN_PRIORITY, 50, Status.DESELECT, true, [Status.DESELECT])
            );
        
        public function TouchSwitch(tapRange:Number=5, multistageStatusConfig:Array = null)
        {
            super(tapRange, multistageStatusConfig || CONFIG_LIST);
        }
        
        public function select():void
        {
            _updateStatus(GROUP_SELECT, Status.SELECT);
        }
        
        public function deselect():void
        {
            _updateStatus(GROUP_SELECT, Status.DESELECT);
        }
        
        public function isSelected():Boolean
        {
            return _status.getGroupStatus(GROUP_SELECT).equal(Status.SELECT);
        }
        
        public function toggleSelect():void
        {
            isSelected() ? deselect(): select();
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case GROUP_SELECT:
                    switch(status)
                    {
                        case Status.SELECT:
                            _onSelected();
                            return true;
                            
                        case Status.DESELECT:
                            _onDeselected();
                            return true;
                    }
            }
            return super._applyStatus(group, status);
        }
        
        override protected function _onClick():void
        {
            _updateStatus(GROUP_SELECT, Status.SELECT);
        }
        
        override protected function _onStealthClick():void
        {
            toggleSelect();
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