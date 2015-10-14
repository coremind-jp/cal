package jp.coremind.control
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Thread;

    public class SyncProcessController extends Controller
    {
        private static const TAG:String = "SyncProcessController";
        Log.addCustomTag(TAG);
        
        protected var
            _numRunning:int,
            _processList:Object;
        
        /**
         * アプリケーションと動機的に実行するProcessを制御するクラス.
         * このクラスから生成されたProcessインスタンスの実行時、その処理が終了するまでアプリケーションはユーザー入力を受け付けなくなる.
         */
        public function SyncProcessController(...params)
        {
            _numRunning = 0;
            _processList = {};
        }
        
        /**　ProcessクラスのpushThreadメソッドと動議　*/
        public function pushThread(processId:String, thread:Thread, parallel:Boolean, async:Boolean = false):SyncProcessController
        {
            var p:Process = processId in _processList ?
                _processList[processId]:
                _processList[processId] = new Process(processId);
            
            p.pushThread(thread, parallel, async);
            
            return this;
        }
        
        /**　Processクラスのexecメソッドと動議　*/
        public function run(processId:String, callback:Function = null):void
        {
            if (processId in _processList)
            {
                Log.custom(TAG, "exec", processId);
                
                var p:Process = _processList[processId];
                delete _processList[processId];
                
                if (_numRunning++ == 0)
                {
                    if (starlingRoot) starlingRoot.disablePointerDevice();
                    if (flashRoot)    flashRoot.disablePointerDevice();
                }
                
                p.exec(function(res:Process):void
                {
                    if (--_numRunning == 0)
                    {
                        if (starlingRoot) starlingRoot.enablePointerDevice();
                        if (flashRoot)    flashRoot.enablePointerDevice();
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