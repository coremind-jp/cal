package jp.coremind.utility.data
{
    public class NumberTracker extends Progress
    {
        private var
            _start:Number,
            _previous:Number,
            _previousDelta:Number,
            _latestTotalDelta:Number;
        
        /**
         * 数値の変動を追跡するクラス.
         */
        public function NumberTracker()
        {
            _start = _previousDelta = _previous = _latestTotalDelta = 0;
        }
        
        public function clone():NumberTracker
        {
            var result:NumberTracker = new NumberTracker();
            
            result._start            = _start;
            result._previous         = _previous;
            result._previousDelta    = _previousDelta;
            result._latestTotalDelta = _latestTotalDelta;
            
            return result;
        }
        
        /**
         * 初期値を設定する.
         * @param   start   初期値
         */
        public function initialize(start:Number):void
        {
            _previousDelta = _latestTotalDelta = 0;
            
            _start = _previous = start;
            update(_start);
        }
        
        /**
         * 値を更新する.
         * @param   n   更新値
         */
        override public function update(n:Number):Boolean
        {
            _previous = now;
            
            super.update(n);
            
            _previousDelta = now - _previous;
            _latestTotalDelta = now - _start;
            
            return _previous !== now;
        }
        
        /**
         * 値をパーセンテージで更新する.
         * @param   per   更新値
         */
        override public function updateByRate(per:Number):Boolean
        {
            _previous = now;
            
            super.updateByRate(per);
            
            _previousDelta = now - _previous;
            _latestTotalDelta   = now - _start;
            
            return _previous !== now;
        }
        
        /** 初期値を取得する. */
        public function get start():Number
        {
            return _start;
        }

        /** 直前に更新された値を取得する. */
        public function get previous():Number
        {
            return _previous;
        }
        
        /** 最後に更新された値と直前に更新された値の差を取得する. */
        public function get previousDelta():Number
        {
            return _previousDelta;
        }
        
        /** 初期値と最後に更新された値の差を取得する. */
        public function get latestTotalDelta():Number
        {
            return _latestTotalDelta;
        }
        
        override public function toString():String
        {
            return super.toString()+" start="+_start+" previous="+_previous+" previousDelta="+_previousDelta+" latestTotalDelta="+_latestTotalDelta;
        }
    }
}