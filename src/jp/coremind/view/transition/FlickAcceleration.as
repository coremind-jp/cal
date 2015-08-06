package jp.coremind.view.transition
{
    import jp.coremind.core.Application;
    import jp.coremind.utility.data.NumberTracker;
    
    /**
     * フリック時の加速度を計算するクラス.
     */
    public class FlickAcceleration
    {
        private var
            _slideFriction:Number,
            _slidAcceleration:Number,
            
            _springFriction:Number,
            _springAcceleration:Number,
            
            _springAccelerationRate:Number;
        
        public function FlickAcceleration(
            slideFriction:Number = 0.05,
            springFriction:Number = 0.2,
            springAccelerationRate:Number = 0.90)
        {
            _slideFriction  = slideFriction;
            _springFriction = springFriction
            _springAccelerationRate = springAccelerationRate;
            
            terminate();
        }
        
        /**
         * 現在のフリックの加速度、とバネ加速度を0にする.
         */
        public function terminate():void
        {
            _slidAcceleration = _springAcceleration = 0;
        }
        
        /**
         * フリックの加速度、とバネ加速度を更新する.
         */
        public function update(v:NumberTracker, elapsed:Number):Boolean
        {
            var _v:Number = 0;
            
            _updateSlideAcceleration(v);
            
            _v = _slidAcceleration * elapsed;
            
            _updateSpringAcceleration(v);
            
            _v += _springAcceleration;
            
            v.update(_adjust(v, _v));
            
            //Log.info(Math.abs(_springAcceleration), _slidAcceleration);
            return 0.025 < Math.abs(_springAcceleration) || _slidAcceleration != 0;
        }
        
        /**
         * フリックの加速度、とバネ加速度を初期化する.
         */
        public function initialize(v:NumberTracker):void
        {
            _slidAcceleration = requireUpdate(v) ? v.preventDelta / Application.stage.frameRate: 0;
            _springAcceleration = 0;
        }
        
        /**
         * フリックが発生し, コンテナを移動たかを示す値を返す.
         */
        public function requireUpdate(v:NumberTracker):Boolean
        {
            if      (v.now < v.min || v.max < v.now)         return true;
            else if (v.preventDelta < 0 && v.totalDelta < 0) return true;
            else if (0 < v.preventDelta && 0 < v.totalDelta) return true;
            else return false;
        }
        
        /**
         * フリック加速度を更新する.
         */
        private function _updateSlideAcceleration(v:NumberTracker):void
        {
            if (_slidAcceleration < 0)
            {
                _slidAcceleration += _slideFriction;
                
                if (0 < _slidAcceleration || v.now <= v.min)
                    _slidAcceleration = 0;
            }
            else
            if (0 < _slidAcceleration)
            {
                _slidAcceleration -= _slideFriction;
                
                if (_slidAcceleration < 0 || v.max <= v.now)
                    _slidAcceleration = 0;
            }
        }
        
        /**
         * バネ加速度を更新する.
         */
        private function _updateSpringAcceleration(v:NumberTracker):void
        {
            if      (v.now < v.min) _springAcceleration += (v.min - v.now) * _springAccelerationRate;
            else if (v.max < v.now) _springAcceleration -= (v.now - v.max) * _springAccelerationRate;
            _springAcceleration *= _springFriction;
        }
        
        /**
         * 加速度をパラメータvへ適応し値を丸め込む.
         */
        private function _adjust(v:NumberTracker, delta:Number):Number
        {
            var _now:Number = v.now + delta;
            
            if (_springAcceleration < 0 && _now < v.max)
            {
                _springAcceleration = 0;
                return v.max;
            }
            else
            if (0 < _springAcceleration && v.min < _now)
            {
                _springAcceleration = 0;
                return v.min;
            }
            else
                return _now;
        }
    }
}