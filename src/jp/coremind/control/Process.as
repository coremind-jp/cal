package jp.coremind.control
{
    import jp.coremind.data.List;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.Status;
    
    public class Process
    {
        public static const TAG:String = "[Process]";
        Log.addCustomTag(TAG);
        
        private var
            _processRoutine:Routine,
            _threadList:List,
            _functionList:List;
        
        public function Process(name:String)
        {
            _processRoutine = new Routine(name);
            _threadList     = new List([]);
            _functionList   = new List([]);
        }
        
        public function get name():String      { return _processRoutine.name; }
        public function get phase():String     { return _processRoutine.phase.status; }
        public function get result():String    { return _processRoutine.result.status; }
        public function get progress():Number  { return _processRoutine.progress.rate; }
        public function readData(key:String):* { return $.hash.read(_processRoutine.memory || {}, key); }
        public function terminate():void       { _processRoutine.terminate(); }
        
        private function _terminate():void
        {
            for (var i:int = 0; i < _threadList.length; i++) 
                (_threadList.getElement(i) as Thread).terminate();
        }
        
        public function updateProgress():void
        {
            var n:Number = 0;
            var t:int    = 0;
            
            for (var i:int = 0; i < _threadList.length; i++) 
            {
                var thread:Thread = _threadList.getElement(i) as Thread;
                n += thread._threadRoutine.weight * thread.progress;
                t += thread._threadRoutine.weight;
            }
            
            _processRoutine.updateProgress(0, t, n);
        }
        
        public function pushThread(thread:Thread, parallel:Boolean, async:Boolean = false):Process
        {
            if (_processRoutine.phase.equal(Status.IDLING))
            {
                _threadList.source.push(thread);
                _functionList.source.push(function(r:Routine):void
                {
                    if (async)
                    {
                        thread.execForProcess(_doneThread, parallel, _processRoutine.memory);
                        if (_nextThread()) _functionList.headElement(r);
                    }
                    else
                        thread.execForProcess(function(t:Thread):void
                        {
                            _doneThread(t);
                            if (t.result !== Status.TERMINATE && _nextThread())
                                _functionList.headElement(r);
                        }, parallel, _processRoutine.memory);
                });
            }
            else Log.custom(TAG, _processRoutine.name+" pushThread cancelled.");
            
            return this;
        }
        
        private function _nextThread():Boolean
        {
            return _threadList.next() && _functionList.next();
        }
        
        public function exec(callback:Function = null):void
        {
            var _self:Process = this;
            var _callback:Function = function(r:Routine):void
            {
                if (callback is Function) $.call(callback, _self);
                _unbindThread();
            };
            
            if (_threadList.length == 0)
                _callback(null);
            else
            {
                _processRoutine.terminateHandler = _terminate;
                _processRoutine.exec(_functionList.headElement, {}, _callback);
            }
        }
        
        private function _doneThread(t:Thread):void
        {
            updateProgress();
            
            if (t.result === Status.FATAL)
                terminate();
            else
            if (t.result === Status.TERMINATE || (_threadList.isLast() && isFinished()))
                _done()
        }
        
        private function isFinished():Boolean
        {
            for (var i:int = 0; i < _threadList.length; i++) 
            {
                var t:Thread = _threadList.getElement(i) as Thread;
                if (t.phase !== Status.FINISHED) return false;
            }
            return true;
        }
        
        private function _done():void
        {
            if      (_has(Status.FATAL))     _processRoutine.fatal();
            else if (_has(Status.TERMINATE)) _processRoutine.terminate();
            else if (_has(Status.FAILED))    _processRoutine.failed();
            else                             _processRoutine.scceeded();
        }
        
        private function _has(expect:String):Boolean
        {
            for (var i:int = 0; i < _threadList.length; i++) 
                if ((_threadList.getElement(i) as Thread).result === expect)
                    return true;
            return false;
        }
        
        private function _unbindThread():void
        {
            if (_processRoutine.resetStatus())
            {
                _threadList.jump(0);
                _functionList.jump(0);
                
                for (var i:int = 0; i < _threadList.length; i++) 
                    (_threadList.getElement(i) as Thread).unbindRoutine();
                
                _threadList.source.length = 0;
                _functionList.source.length = 0;
            }
        }
        
        public function dumpStatus():void
        {
            Log.custom(TAG, _processRoutine.name+" phase ["+_processRoutine.phase.status+"] result:["+_processRoutine.result.status+"].");
            for (var i:int = 0; i < _threadList.length; i++) 
                (_threadList.getElement(i) as Thread).dumpStatus();
        }
    }
}