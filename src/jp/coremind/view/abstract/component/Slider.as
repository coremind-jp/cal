package jp.coremind.view.abstract.component
{
    import jp.coremind.data.Progress;
    
    /**
     * 
     */
    public class Slider
    {
        private var
            _grid:Grid3,
            _percentage:Number,
            _size:Number,
            _position:Number,
            _progress:Progress,
            _containerSize:Number;
        
        /**
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
        
        public function destroy():void
        {
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
            
            _grid.visible  = _percentage < 1;
            _grid.size     = _size * _percentage;
            
            _progress.setRange(0, _containerSize - _grid.size);
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
        }
        
        public function toString():String
        {
            return "containerSize="+_containerSize+" sliderSize="+_size+"("+_percentage+") progress="+_progress.toString();
        }
    }
}