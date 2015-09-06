package jp.coremind.control
{
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Thread;

    public class SyncProcessController extends Controller
    {
        protected var
            _numRunning:int,
            _processList:Object;
        
        /**
         * アプリケーションと動機的に実行するProcessを制御するクラス.
         * このクラスから生成されたProcessインスタンスの実行時、その処理が終了するまでアプリケーションはユーザー入力を受け付けなくなる.
         */
        public function SyncProcessController()
        {
            _numRunning = 0;
            _processList = {};
        }
        
        /**　ProcessクラスのpushThreadメソッドと動議　*/
        public function pushThread(processName:String, thread:Thread, parallel:Boolean, async:Boolean = false):SyncProcessController
        {
            var p:Process = processName in _processList ?
                _processList[processName]:
                _processList[processName] = new Process(processName);
            
            p.pushThread(thread, parallel, async);
            
            return this;
        }
        
        /**　Processクラスのexecメソッドと動議　*/
        public function exec(processName:String, callback:Function = null):void
        {
            if (processName in _processList)
            {
                var p:Process = _processList[processName];
                delete _processList[processName];
                
                if (_numRunning++ == 0)
                {
                    gpuView.disablePointerDevice();
                    cpuView.disablePointerDevice();
                }
                
                p.exec(function(res:Process):void
                {
                    if (--_numRunning == 0)
                    {
                        gpuView.enablePointerDevice();
                        cpuView.enablePointerDevice();
                    }
                    
                    if (callback is Function)
                        callback(res);
                });
            }
        }
        
        /** 現在実行中のProcessインスタンスが存在するかを示す値を返す. */
        public function isRunning():Boolean
        {
            return _numRunning > 0;
        }
    }
}