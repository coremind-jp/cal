package jp.coremind.control
{
    import jp.coremind.data.Progress;
    import jp.coremind.utility.Log;

    public class Loop
    {
        protected var _handlerList:Array;
        
        public function Loop()
        {
            _handlerList = [];
        }
        
        public function terminate():void
        {
            _handlerList.length = 0;
            _handlerList = null;
        }
        
        protected function _update(v:* = null):void
        {
            try {
                for (var i:int = 0, len:int = _handlerList.length; i < len; i++) 
                {
                    if (_handlerList[i](v))
                    {
                        _handlerList.splice(i, 1);
                        Log.info("delete Loop call back.", _handlerList.length);
                        len--;
                        i--;
                    }
                }
            } catch (e:Error) { Log.error("Loop callback error. message("+e.message+")"); }
        }
        
        public function createWaitProcess(delay:int):Function
        {
            return function(p:Routine, t:Thread):void { pushHandler(delay, p.scceeded); };
        }
        
        public function setTimeout(delay:int, f:Function, ...args):void
        {
            pushHandler(delay, function(p:Progress):Boolean { return $.apply(f, args); });
        }
        
        public function pushHandler(delay:int, completeClosure:Function, updateClosure:Function = null):void {}
    }
}