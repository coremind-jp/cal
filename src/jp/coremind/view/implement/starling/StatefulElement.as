package jp.coremind.view.implement.starling
{
    import jp.coremind.utility.MultistageStatus;
    
    /**
     * Elementクラスに状態機能を加えたクラス.
     */
    public class StatefulElement extends Element
    {
        protected var
            _runningUpdate:Boolean,
            _status:MultistageStatus;
        
        public function StatefulElement(multistageStatusConfig:Array = null)
        {
            super();
            
            _runningUpdate = false;
            
            _status = new MultistageStatus(multistageStatusConfig || []);
        }
        
        override public function destroy():void
        {
            _status.destroy();
            
            super.destroy();
        }
        
        override public function reuseInstance():void
        {
            super.reuseInstance();
            
            _initializeStatus();
        }
        
        /**
         * ステータスを初期化する.
         */
        protected function _initializeStatus():void {}
        
        /**
         * 現在のMultistageStatus.group, valueをパラメータstatusGroupをstatusValueへ更新する.
         * この際に直前まで保持していたgroupとvalueいずれか一つでも異なっている場合、_applyStatusメソッドを呼び出す。
         * 例外としてGROUP_CTRLグループのStatus.MOVEステータスのみ常に_applyStatusを呼び出す。
         * ステータスの更新によって暗黙的にステータスグループに変更があった際に、そのハンドリングを正しく呼び出すためのメソッド。
         */
        protected function _updateStatus(statusGroup:String, statusValue:String):Boolean
        {
            if (!statusValue) return false;
            
            var beforeGroup:String        =  _status.headGroup;
            var beforeStatus:String       =  _status.headStatus;
            var updateLog:Vector.<String> =  _status.update(statusGroup, statusValue);
            var doApplyStatus:Boolean     = !_status.equalGroup(beforeGroup) || !_status.equal(beforeStatus);
            
            if (doApplyStatus)
            {
                _runningUpdate = true;
                
                if (updateLog.length > 1)
                    updateLog = updateLog.slice();
                
                for (var i:int = 0, len:int = updateLog.length; _runningUpdate && i < len; i++)
                    _applyStatus(updateLog[i], _status.getGroupStatus(updateLog[i]).value);
                
                _runningUpdate = false;
            }
            
            return doApplyStatus;
        }
        
        /**
         * 現在のMultistageStatusオブジェクトが示すステータス値にしたがって対応したコールバックを呼び出す.
         */
        protected function _applyStatus(group:String, status:String):Boolean
        {
            return false;
        }
    }
}