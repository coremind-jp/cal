package jp.coremind.module
{
    import jp.coremind.utility.data.Status;

    public class StatusConfigure
    {
        private var
            _group:String,
            _updateRule:String,
            _priority:int,
            _initialStatus:String,
            _includeDownStageLog:Boolean,
            _stageDownStatus:Array;
        
        /**
         * @param   group               ステータスを管理するためのグループ名
         * @param   updateRule          ステータス更新ルール
         * @param   priority            このStatusConfigureオブジェクトを内包するMultistageStatusオブジェクト内での優先度
         * @param   initialStatus       ステータス初期値
         * @param   includeDownStageLog ステージダウンが発生した場合にステータス更新ログにこのステータスの更新を求めるかを示す値
         * @param   stageDownStatus     このグループ内でステージダウンを発生させるステータス定数を格納する配列
         */
        public function StatusConfigure(
            group:String,
            updateRule:String = UpdateRule.LESS_THAN_PRIORITY,
            priority:int = 0,
            initialStatus:String = Status.IDLING,
            includeDownStageLog:Boolean = false,
            stageDownStatus:Array = null)
        {
            _group               = group;
            _updateRule          = updateRule;
            _priority            = priority;
            _initialStatus       = initialStatus;
            _includeDownStageLog = includeDownStageLog;
            _stageDownStatus     = stageDownStatus || [];
        }
        
        /**
         * 初期ステータスを取得する
         */
        public function get initialStatus():String
        {
            return _initialStatus;
        }
        
        /**
         * ステータスグループ名を取得する.
         */
        public function get group():String
        {
            return _group;
        }

        /**
         * ステータスのアップデートルールを取得する.
         */
        public function get updateRule():String
        {
            return _updateRule;
        }

        /**
         * ステータスの優先度を取得する.
         */
        public function get priority():int
        {
            return _priority;
        }

        /**
         * 一つ低いプライオリティを持つステータスグループへ状態を落とす為のステータスが設定されているかを示す値を返す.
         */
        public function definedStageDownStatus():Boolean
        {
            return _stageDownStatus.length > 0;
        }
        
        /**
         * ダウンステージ時にアップデートログにこのグループステータスを含めるかを示す値を返す.
         */
        public function get includeDownStageLog():Boolean
        {
            return _includeDownStageLog;
        }
        
        /**
         * パラメータstatusが一つ低いプライオリティを持つステータスグループへ状態を落とす為のステータスとして設定されているかを示す値を返す.
         */
        public function invokableStageDown(status:String):Boolean
        {
            return _stageDownStatus.indexOf(status) != -1;
        }
        
        public function toString():String
        {
            return "group\t\t"+_group
            +"\nupdateRule\t\t"+_updateRule
            +"\npriority\t\t"+_priority
            +"\ninitialStatus\t\t"+_initialStatus
            +"\nincludeDownStageLog\t"+_includeDownStageLog
            +"\nstageDownStatus\t\t"+_stageDownStatus;
        }
    }
}