package jp.coremind.view.implement.starling.component
{
    import jp.coremind.utility.MultistageStatus;
    import jp.coremind.utility.Status;
    import jp.coremind.view.implement.starling.InteractiveElement;
    
    import starling.events.Touch;

    /**
     * Buttonクラスにスイッチ機能を加えたクラス.
     */
    public class Switch extends Button
    {
        public static const GROUP_SELECT:String = "groupSelect";
        
        private static const PRIORITY_LIST:Array = MultistageStatus.margePriorityList(
            InteractiveElement.PRIORITY_LIST, { 
                group: GROUP_SELECT, ignorePriority:false, priority: 50, initialStatus:Status.DESELECT, decrementCondition: [Status.DESELECT]
            });
        
        public function Switch(tapRange:Number=5, multistageStatusConfig:Array = null)
        {
            super(tapRange, multistageStatusConfig || PRIORITY_LIST);
        }
        
        /**
         * 選択状態にする.
         */
        public function select():void
        {
            _updateStatus(GROUP_SELECT, Status.SELECT);
        }
        
        /**
         * 非選択状態にする.
         */
        public function deselect():void
        {
            _updateStatus(GROUP_SELECT, Status.DESELECT);
        }
        
        /**
         * 選択中かを示す値を返す.
         */
        public function isSelected():Boolean
        {
            return _status.getGroupStatus(GROUP_SELECT).equal(Status.SELECT);
        }
        
        /**
         * 選択・選択解除を反転させる.
         */
        public function toggle():void
        {
            if (isSelected())
            {
                //deselectでstatusの参照がSTATUS_GROUP_CTRLへ変わる(STATUS_GROUP_CTRLのStatus.CLICK)ので
                //自身をクリックしてトグルした場合に備えて再びselectに遷移しないようにrollOverに変えておく
                _status.update(GROUP_CTRL, _intersects() ? Status.ROLL_OVER: Status.ROLL_OUT);
                deselect();
            }
            else　select();
        }
        
        override protected function _applyStatus(t:Touch = null):void
        {
            super._applyStatus(t);
            
            if (_status.equalGroup(GROUP_SELECT))
            {
                switch(_status.value)
                {
                    case Status.SELECT: _onSelected(t); break;
                }
            }
        }
        
        override protected function _onClick(t:Touch):void
        {
            _updateStatus(GROUP_SELECT, Status.SELECT);
        }
        
        override protected function _onStealthClick(t:Touch):void
        {
            toggle();
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_SELECT
         * value : Status.SELECT
         */
        protected function _onSelected(t:Touch):void
        {
            _tf.text = ">>selected";
            _quad.color = 0x00ffff;
        }
    }
}