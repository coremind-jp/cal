package jp.coremind.view.abstract.component
{
    import jp.coremind.utility.data.Progress;
    
    import starling.animation.Transitions;
    import starling.animation.Tween;
    import starling.core.Starling;
    
    public class Slider
    {
        private var
            _grid:Grid3,
            _fadeIn:Tween,
            _fadeOut:Tween,
            _percentage:Number,
            _size:Number,
            _position:Number,
            _progress:Progress,
            _containerSize:Number;
        
        /**
         * Grid3を継承したクラスインスタンスを利用したスライド制御クラス.
         * @param   grid3       スライダーとなるグラフィックリソース
         * @param   size        スライダーの稼動範囲
         * @param   position    スライド方向の初期座標
         */
        public function Slider(grid3:Grid3, size:Number, position:Number)
        {
            _grid     = grid3;
            _size     = size;
            _position = position;
            
            _progress = new Progress();
            _progress.enabledRound = false;
        }
        
        public function destroy(withReference:Boolean):void
        {
            _fadeIn = _fadeOut = null;
            Starling.juggler.remove(_fadeIn);
            Starling.juggler.remove(_fadeOut);
            
            if (withReference) _grid.destroy();
            
            _grid = null;
        }
        
        /**
         * このスライダーとリンクさせるコンテナの稼動範囲を設定する.
         * @param   pageSize        コンテナが保持するコンテンツの幅
         * @param   containerSize   コンテナの幅
         */
        public function setRange(pageSize:Number, containerSize:Number):void
        {
            _containerSize = containerSize;
            _percentage    = _containerSize / pageSize;
            
            _grid.asset.visible = _percentage < 1;
            _grid.size          = _size * _percentage;
            
            _progress.setRange(0, _containerSize - _grid.size, false);
            
            _beginFadeAnimation();
        }
        
        /**
         * スライダーの状態をpercentageパラメータを元に更新する.
         * @param   percentage  現在の位置を0-1で指定する
         */
        public function update(percentage:Number):void
        {
            var threshold:Number;
            var defaultSize:Number;
            var overflowDelta:Number;
            
            _progress.updateByRate(percentage);
            
            if (_progress.now < _progress.min)
            {
                threshold     = _containerSize >> 1;
                overflowDelta = _progress.min - _progress.now;
                defaultSize   = _size * _percentage;
                
                _grid.size     = defaultSize - (overflowDelta / threshold * defaultSize);
                _grid.position = _position + _size - _grid.size;
            }
            else
            if (_progress.max < _progress.now)
            {
                threshold     = _containerSize >> 1;
                overflowDelta = _progress.now - _progress.max;
                defaultSize   = _size * _percentage;
                
                _grid.size     = defaultSize - (overflowDelta / threshold * defaultSize);
                _grid.position = _position;
            }
            else
            {
                defaultSize = (1 - _percentage) * _size;
                
                _grid.size     = _size * _percentage;
                _grid.position = _position + defaultSize * (1 - _progress.rate);
            }
            
            _beginFadeAnimation();
        }
        
        private function _beginFadeAnimation():void
        {
            if (_fadeIn || !_grid.asset.visible) return;
            
            if (_fadeOut) Starling.juggler.remove(_fadeOut);
            
            _fadeIn = new Tween(_grid.asset, .2, Transitions.LINEAR);
            _fadeIn.animate("alpha", 1);
            _fadeIn.onComplete = function():void
            {
                _fadeIn  = null;
                _fadeOut = new Tween(_grid.asset, .2, Transitions.LINEAR);
                _fadeOut.delay = .2;
                _fadeOut.animate("alpha", 0);
                _fadeOut.onComplete = function():void { _fadeOut = null; }
                Starling.juggler.add(_fadeOut);
            };
            Starling.juggler.add(_fadeIn);
        }
        
        public function toString():String
        {
            return "containerSize="+_containerSize+" sliderSize="+_size+"("+_percentage+") progress="+_progress.toString();
        }
    }
}