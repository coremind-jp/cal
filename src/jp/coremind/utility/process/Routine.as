package jp.coremind.utility.process
{
    import jp.coremind.utility.data.Progress;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;

    public class Routine
    {
        public static const TAG:String = "[Routine]";
        Log.addCustomTag(TAG);
        
        public static const SKIP:Function = function(r:Routine, t:Thread):void { r.scceeded(); };
        
        public var weight:int;
        
        private var
            _name:String,
            _phase:Status,
            _result:Status,
            _progress:Progress,
            _memory:Object,
            _terminateHandler:Function,
            _callback:Function;
        
        public function Routine(name:String = "", progressWeight:int = 1)
        {
            weight    = progressWeight;
            _name     = name;
            
            _phase    = new Status(Status.IDLING);
            _result   = new Status(Status.IDLING);
            _progress = new Progress();
        }
        
        public   function set terminateHandler(f:Function):void { _terminateHandler = f; }
        public   function get name():*            { return _name; }
        internal function get progress():Progress { return _progress; }
        internal function get phase():Status      { return _phase; }
        internal function get result():Status     { return _result; }
        internal function get memory():Object     { return _memory; }
        
        internal function exec(f:Function, memory:Object, callback:Function = null):void
        {
            if (_phase.equal(Status.IDLING, _name+" tryIt cancelled. "))
            {
                Log.custom(TAG, _name+" [execute]");
                _phase.update(Status.RUNNING);
                _progress.reset();
                
                _memory   = memory;
                _callback = callback;
                try { f(this); } catch (e:Error) { fatal("Routine error. message("+e.message+")\n"+e.getStackTrace()); }
            }
        }
        
        public function writeData(key:String, value:* = null):void
        {
            if (_memory) $.hash.write(_memory, key, value);
        }
        
        public function updateData(key:String, value:* = null):void
        {
            if (_memory)
            {
                var data:Object = {};
                data[key] = value;
                $.hash.update(_memory, data);
            }
        }
        
        public function updateProgress(min:Number, max:Number, now:Number):void
        {
            _progress.setRange(min, max);
            _progress.update(now);
        }
        
        internal function terminate():void                  { _done(Status.TERMINATE, "[terminate]"); }
        public   function scceeded(report:String = ""):void { _done(Status.SCCEEDED,  "[scceeded] " + report); }
        public   function failed(report:String = ""):void   { _done(Status.FAILED,    "[failed] "   + report); }
        public   function fatal(report:String = ""):void    { _done(Status.FATAL,     "[fatal] "    + report); }
        
        private function _done(resultStatus:String, report:String):void
        {
            var _invalidReport:String = resultStatus === Status.TERMINATE ? null: _name+" "+resultStatus+" cancelled.";
            
            if (_phase.equal(Status.RUNNING, _invalidReport))
            {
                Log.custom(TAG, _name+" "+report);
                
                _phase.update(Status.FINISHED);
                _result.update(resultStatus);
                _progress.forcedComplete();
                
                if (resultStatus === Status.TERMINATE)
                    if (_terminateHandler is Function)
                        $.call(_terminateHandler);
                
                if (_callback is Function) $.call(_callback, this);
            }
        }
        
        internal function resetStatus():Boolean
        {
            if (_phase.equal(Status.FINISHED, _name+" resetStatus cancelled. "))
            {
                Log.custom(TAG, _name+" [resetStatus]");
                _phase.update(Status.IDLING);
                _result.update(Status.IDLING);
                _progress.reset();
                
                _memory           = null;
                _callback         = null;
                _terminateHandler = null;
                return true;
            }
            else
                return false;
        }
        
        internal function dumpStatus():void
        {
            Log.custom(TAG, _name+" phase["+_phase.value+"] result["+_result.value+"]");
        }
    }
}