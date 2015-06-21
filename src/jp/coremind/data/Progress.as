package jp.coremind.data
{
    import jp.coremind.utility.Log;

    public class Progress
    {
        public var enabledRound:Boolean;
        
        private var
            _min:Number,
            _max:Number,
            _now:Number;
            
        public function Progress()
        {
            enabledRound = true;
            _now = 0;
            setRange();
        }
        
        public function setRange(min:Number = 0, max:Number = 1):void
        {
            if (max < min)
            {
                Log.warning("invalid value. (Progress) min:"+min+" max:"+max);
                _min = 0;
                _max = 1;
            }
            else
            {
                _min = min;
                _max = max;
            }
            update(_now);
        }
        
        public function get now():Number  { return _now; }
        public function get min():Number  { return _min; }
        public function get max():Number  { return _max; }
        
        public function get gain():Number { return _now - _min; }
        public function get rate():Number { return gain / (_max - _min); }
        
        public function forcedComplete():void { _now = _max; }
        public function reset():void          { _now = _min; }
        
        public function update(now:Number):Boolean
        {
            if (enabledRound)
            {
                if      (isNaN(now)) _now = _min;
                else if (now < _min) _now = _min;
                else if (_max < now) _now = _max;
                else                 _now =  now;
            }
            else
                _now = isNaN(now) ? _min: now;
            
            return true;
        }
    }
}