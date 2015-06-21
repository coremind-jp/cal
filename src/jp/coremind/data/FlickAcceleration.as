package jp.coremind.data
{
    import jp.coremind.control.Application;

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
            springFriction:Number = 0.7,
            springAccelerationRate:Number = 0.1)
        {
            _slideFriction  = slideFriction;
            _springFriction = springFriction
            _springAccelerationRate = springAccelerationRate;
            
            terminate();
        }
        
        public function terminate():void
        {
            _slidAcceleration = _springAcceleration = 0;
        }
        
        public function update(v:NumberTracker, elapsed:Number):void
        {
            var _v:Number = 0;
            
            _v += _slidAcceleration * elapsed;
            _updateSlideAcceleration(v);
            
            _updateSpringAcceleration(v);
            _v += _springAcceleration;
            
            v.update(_adjust(v, _v));
        }
        
        public function initialize(v:NumberTracker):void
        {
            _slidAcceleration = _isFlick(v) ? v.preventDelta / Application.stage.frameRate: 0;
            _springAcceleration = 0;
        }
        
        protected function _isFlick(v:NumberTracker):Boolean
        {
            if      (v.preventDelta < 0 && v.totalDelta < 0) return true;
            else if (0 < v.preventDelta && 0 < v.totalDelta) return true;
            else return false;
        }
        
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
        
        private function _updateSpringAcceleration(v:NumberTracker):void
        {
            if      (v.now < v.min) _springAcceleration += (v.min - v.now) * _springAccelerationRate;
            else if (v.max < v.now) _springAcceleration -= (v.now - v.max) * _springAccelerationRate;
            _springAcceleration *= _springFriction;
        }
        
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
                return v.now + delta;
        }
    }
}