package jp.coremind.control
{
    import jp.coremind.utility.process.Process;

    public class AsyncProcessController extends SyncProcessController
    {
        private var
            _runningProcess:Vector.<String>;
        
        public function AsyncProcessController(...params)
        {
            super();
            _runningProcess = new <String>[];
        }
        
        override public function run(processName:String, callback:Function=null):void
        {
            if (processName in _processList && _runningProcess.indexOf(processName) == -1)
            {
                _runningProcess.push(processName);
                
                (_processList[processName] as Process).exec(callback);
            }
        }
        
        /**　現在実行中の全Processインスタンスを強制停止させる　*/
        public function terminate(processName:String):void
        {
            var i:int = _runningProcess.indexOf(processName);
            if (i != -1)
            {
                var p:Process = _processList[processName];
                
                delete _processList[processName];
                _runningProcess.splice(i, 1);
                
                p.terminate();
            }
        }
        
        public function terminateAll():void
        {
            for (var processName:String in _processList) terminate(processName);
        }
    }
}