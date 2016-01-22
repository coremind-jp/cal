package jp.coremind.core
{
    import flash.utils.setTimeout;
    
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Thread;

    public class SyncProcess extends ViewAccessor
    {
        private static const TAG:String = "[SyncProcess]";
        Log.addCustomTag(TAG);
        
        protected var
            _que:Vector.<Function>,
            _numRunning:int,
            _processList:Object;
        
        /**
         * アプリケーションと動機的に実行するProcessを制御するクラス.
         * このクラスから生成されたProcessインスタンスの実行時、その処理が終了するまでアプリケーションはユーザー入力を受け付けなくなる.
         */
        public function SyncProcess()
        {
            _que = new <Function>[];
            _numRunning = 0;
            _processList = {};
        }
        
        /**　ProcessクラスのpushThreadメソッドと動議　*/
        public function pushThread(processId:String, thread:Thread, parallel:Boolean, async:Boolean = false):SyncProcess
        {
            var p:Process = processId in _processList ?
                _processList[processId]:
                _processList[processId] = new Process(processId);
            
            p.pushThread(thread, parallel, async);
            
            return this;
        }
        
        /**　Processクラスのexecメソッドと動議　*/
        public function exec(processId:String, callback:Function = null):void
        {
            if (processId in _processList)
            {
                var p:Process = _processList[processId];
                delete _processList[processId];
                
                if (_numRunning++ == 0)
                {
                    if (starlingRoot) starlingRoot.disablePointerDevice();
                    if (flashRoot)    flashRoot.disablePointerDevice();
                }
                Log.custom(TAG, "exec\n [Id] '"+processId+"'", "\n [now runnung]", _numRunning);
                
                p.exec(function(res:Process):void
                {
                    if (callback is Function)
                        callback(res);
                    
                    Log.custom(TAG, "finished\n [Id] '"+processId+"'", "\n [now runnuns]", _numRunning-1);
                    
                    if (--_numRunning == 0)
                    {
                        if (starlingRoot) starlingRoot.enablePointerDevice();
                        if (flashRoot)    flashRoot.enablePointerDevice();
                    }
                });
            }
            else
            if (callback is Function)
            {
                Log.info(TAG, "undefined Process. (Id:'"+processId+"') because callback arguments is null.");
                callback(null);
            }
        }
        
        /** 現在実行中のProcessインスタンスが存在するかを示す値を返す. */
        public function isRunning():Boolean
        {
            return _numRunning > 0;
        }
    }
}