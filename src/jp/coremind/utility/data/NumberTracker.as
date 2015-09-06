package jp.coremind.utility.data
{
    public class NumberTracker extends Progress
    {
        private var
            _start:Number,
            _prevent:Number,
            _preventDelta:Number,
            _totalDelta:Number;
        
        /**
         * 数値の変動を追跡するクラス.
         */
        public function NumberTracker()
        {
            _start = _preventDelta = _prevent = _totalDelta = 0;
        }
        
        /**
         * 初期値を設定する.
         * @param   start   初期値
         */
        public function initialize(start:Number):void
        {
            _preventDelta = _totalDelta = 0;
            
            _start = _prevent = start;
            update(_start);
        }
        
        /**
         * 値を更新する.
         * @param   n   更新値
         */
        override public function update(n:Number):Boolean
        {
            _prevent = now;
            
            super.update(n);
            
            _preventDelta = now - _prevent;
            _totalDelta   = now - _start;
            
            return _prevent !== now;
        }
        
        /** 初期値を取得する. */
        public function get start():Number
        {
            return _start;
        }

        /** 直前に更新された値を取得する. */
        public function get prevent():Number
        {
            return _prevent;
        }
        
        /** 最後に更新された値と直前に更新された値の差を取得する. */
        public function get preventDelta():Number
        {
            return _preventDelta;
        }
        
        /** 初期値と最後に更新された値の差を取得する. */
        public function get totalDelta():Number
        {
            return _totalDelta;
        }
        
        override public function toString():String
        {
            return super.toString()+" start="+_start+" prevent="+_prevent+" preventDelta="+_preventDelta+" totalDelta="+_totalDelta;
        }
    }
}