package jp.coremind.core
{
    import jp.coremind.utility.process.Process;

    public class AsyncProcess extends SyncProcess
    {
        private var
            _runningProcess:Vector.<String>;
        
        public function AsyncProcess(...params)
        {
            super();
            _runningProcess = new <String>[];
        }
        
        override public function exec(processId:String, callback:Function=null):void
        {
            if (processId in _processList && _runningProcess.indexOf(processId) == -1)
            {
                _runningProcess.push(processId);
                
                (_processList[processId] as Process).exec(callback);
            }
        }
        
        /**　現在実行中の全Processインスタンスを強制停止させる　*/
        public function terminate(processId:String):void
        {
            var i:int = _runningProcess.indexOf(processId);
            if (i != -1)
            {
                var p:Process = _processList[processId];
                
                delete _processList[processId];
                _runningProcess.splice(i, 1);
                
                p.terminate();
            }
        }
        
        public function terminateAll():void
        {
            for (var processId:String in _processList) terminate(processId);
        }
    }
}