package jp.coremind.utility.data
{
    import jp.coremind.utility.Log;
    
    /**
     * 任意進捗量を操作するクラス.
     */
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
        
        /**
         * 範囲を指定する.
         */
        public function setRange(min:Number = 0, max:Number = 1, invalidReport:Boolean = true):void
        {
            if (max < min)
            {
                if (invalidReport)
                    Log.info("invalid value. (Progress) min:"+min+" max:"+max);
                _min = 0;
                _max = 0;
            }
            else
            {
                _min = min;
                _max = max;
            }
        }
        
        /**
         * 現在の進捗値を絶対値で取得する.
         */
        public function get now():Number  { return _now; }
        /**
         * 最小値を取得する.
         */
        public function get min():Number  { return _min; }
        /**
         * 最大値を取得する.
         */
        public function get max():Number  { return _max; }
        
        /**
         * 最小値と最大値の幅を取得する.
         */
        public function get distance():Number { return _max - _min; }
        /**
         * 現在の進捗値を相対地で取得する.
         */
        public function get gain():Number { return _now - _min; }
        /**
         * 現在の進捗値を単位値(0~1)で取得する.
         */
        public function get rate():Number
        {
            var a:Number = distance;
            return a == 0 ? a: gain / distance;
        }
        
        /**
         * 現在の進捗値が最小値と最大値の間に含まれるかを示す値を返す.
         */
        public function isOutOfRange():Boolean { return _now < _min || _max < _now; }
        /**
         * 強制的に現在の進捗値を最大値にする.
         */
        public function forcedComplete():void  { _now = _max; }
        /**
         * 強制的に現在の進捗値を最小値にする.
         */
        public function reset():void           { _now = _min; }
        
        /**
         * 進捗値を更新する.
         * enabledRoundがtrueの場合で最小値を下回ったり最大値を上回った場合範囲内に丸め込まれる。
         */
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
        
        /**
         * 進捗値を単位値(0~1)で更新する.
         * enabledRoundがtrueの場合で最小値を下回ったり最大値を上回った場合範囲内に丸め込まれる。
         */
        public function updateByRate(rate:Number):Boolean
        {
            rate = enabledRound ?
                rate < 0 ? 0: 1 < rate ? 1: rate:
                rate;
            
            return update(_min + distance * rate);
        }
        
        public function toString():String
        {
            return "now="+_now+" min="+_min+" max="+_max+" distance="+distance+" gain="+gain;
        }
    }
}