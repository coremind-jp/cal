package jp.coremind.control
{
    import jp.coremind.data.List;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.Status;
    
    public class Thread
    {
        public static const TAG:String = "[Thread]";
        Log.addCustomTag(TAG);
        
        internal var
            _threadRoutine:Routine;
        
        private var
            _leafThreadList:Array,
            _routineList:List,
            _functionList:List;
        
        public function Thread(name:String)
        {
            _threadRoutine  = new Routine(name);
            _leafThreadList = [];
            _routineList    = new List([]);
            _functionList   = new List([]);
        }
        
        public function get name():String      { return _threadRoutine.name; }
        public function get phase():String     { return _threadRoutine.phase.status; }
        public function get result():String    { return _threadRoutine.result.status; }
        public function get progress():Number  { return _threadRoutine.progress.rate; }
        public function readData(key:String):* { return $.hash.read(_threadRoutine.memory || {}, key); }
        public function terminate():void       { _threadRoutine.terminate(); }
        
        private function _terminate():void
        {
            for (var i:int = 0; i < _routineList.length; i++) 
                (_routineList.getElement(i) as Routine).terminate();
            
            while (_leafThreadList.length > 0) 
            {
                var t:Thread = _leafThreadList.pop();
                if (t._threadRoutine.phase.equal(Status.RUNNING))
                    t.terminate();
            }
        }
        
        public function updateProgress():void
        {
            var n:Number = 0;
            var t:int  = 0;
            
            for (var i:int = 0; i < _routineList.length; i++) 
            {
                var r:Routine = _routineList.getElement(i) as Routine;
                n += r.weight * r.progress.rate;
                t += r.weight;
            }
            
            _threadRoutine.updateProgress(0, t, n);
        }
        
        public function pushRoutine(f:Function, args:Array = null, weight:int = 1):Thread
        {
            if (_threadRoutine.phase.equal(Status.IDLING))
            {
                _routineList.source.push(new Routine(_threadRoutine.name+" ["+_routineList.length+"]", weight));
                _functionList.source.push(function(r:Routine, t:Thread):void
                {
                    $.apply(f, args ? new Array(r, t).concat(args): [r, t]);
                });
            }
            else Log.custom(TAG, _threadRoutine.name+" pushRoutine cancelled.");
            
            return this;
        }
        
        public function execLeafThread(t:Thread, callback:Function = null, parallel:Boolean = false):Thread
        {
            if (   t._threadRoutine.phase.equal(Status.IDLING, _threadRoutine.name+" execLeafThread cancelled.")
            &&  this._threadRoutine.phase.equal(Status.RUNNING, _threadRoutine.name+" execLeafThread cancelled."))
            {
                _leafThreadList.push(t);
                t.oneShot(callback, parallel);
            }
            
            return this;
        }
        
        public function exec(callback:Function = null, parallel:Boolean = false):void
        {
            var _self:Thread = this;
            _exec(function(r:Routine):void
            {
                if (callback is Function) $.call(callback, _self);
                resetStatus();
            }, parallel, {});
        }
        
        public function oneShot(callback:Function = null, parallel:Boolean = false):void
        {
            var _self:Thread = this;
            _exec(function(r:Routine):void
            {
                if (callback is Function) $.call(callback, _self);
                unbindRoutine();
            }, parallel, {});
        }
        
        internal function execForProcess(callback:Function, parallel:Boolean, memory:Object):void
        {
            var _self:Thread = this;
            _exec(function(r:Routine):void
            {
                if (callback is Function) $.call(callback, _self);
            }, parallel, memory);
        }
        
        private function _exec(callback:Function, parallel:Boolean, memory:Object):void
        {
            if (_routineList.length == 0)
                callback(null);
            else
            {
                _threadRoutine.terminateHandler = _terminate;
                _threadRoutine.exec(parallel ? _execParallel: _execSeriarl, memory, callback);
            }
        }
        
        internal function unbindRoutine():void//*unitTest用にinternalにしている。本来であればprivate
        {
            if (resetStatus())
            {
                _leafThreadList.length = 0;
                _routineList.source.length = 0;
                _functionList.source.length = 0;
            }
        }
        
        internal function resetStatus():Boolean//*unitTest用にinternalにしている。本来であればprivate
        {
            if (_threadRoutine.resetStatus())
            {
                _routineList.jump(0);
                _functionList.jump(0);
                
                for (var i:int = 0; i < _routineList.length; i++) 
                    (_routineList.getElement(i) as Routine).resetStatus();
                
                return true;
            }
            else
                return false;
        }
        
        private function get _headRoutine():Routine
        {
            return _routineList.headElement;
        }
        
        private function get _headFunction():Function
        {
            var _functionSource:Function = _functionList.headElement;
            var _self:Thread = this;
            return function(r:Routine):void { _functionSource(r, _self); };
        }
        
        private function _execParallel(r:Routine):void
        {
            do { _headRoutine.exec(_headFunction, _threadRoutine.memory, _doneParallel); }
            while (_nextRoutine())
        }
        
        private function _doneParallel(r:Routine):void
        {
            updateProgress();
            
            if (r.result.equal(Status.FATAL))
                terminate();
            else
            if (isFinished())
                _done();
        }
        
        private function isFinished():Boolean
        {
            for (var i:int = 0; i < _routineList.length; i++) 
            {
                var r:Routine = _routineList.getElement(i) as Routine;
                if (!r.phase.equal(Status.FINISHED)) return false;
            }
            return true;
        }
        
        private function _execSeriarl(r:Routine = null):void
        {
            _headRoutine.exec(_headFunction, _threadRoutine.memory, _doneSeriarl);
        }
        
        private function _doneSeriarl(r:Routine):void
        {
            updateProgress();
            
            r.result.equal(Status.FATAL) || r.result.equal(Status.TERMINATE) || !_nextRoutine() ?
                _done():
                _execSeriarl();
        }
        
        private function _nextRoutine():Boolean
        {
            return _routineList.next() && _functionList.next();
        }
        
        private function _done():void
        {
            if      (_has(Status.FATAL))     _threadRoutine.fatal();
            else if (_has(Status.TERMINATE)) _threadRoutine.terminate();
            else if (_has(Status.FAILED))    _threadRoutine.failed();
            else                             _threadRoutine.scceeded();
        }
        
        private function _has(expect:String):Boolean
        {
            for (var i:int = 0; i < _routineList.length; i++) 
                if ((_routineList.getElement(i) as Routine).result.equal(expect))
                    return true;
            return false;
        }
        
        public function dumpStatus():void
        {
            Log.custom(TAG, _threadRoutine.name+" phase ["+_threadRoutine.phase.status+"] result:["+_threadRoutine.result.status+"].");
            for (var i:int = 0; i < _routineList.length; i++) 
                (_routineList.getElement(i) as Routine).dumpStatus();
        }
    }
}