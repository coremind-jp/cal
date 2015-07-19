package jp.coremind.view.abstract.component
{
    import jp.coremind.data.Progress;
    import jp.coremind.view.abstract.IProgressElement;
    
    /**
     * Grid3クラスを応用したゲージ表現クラス.
     */
    public class Gauge implements IProgressElement
    {
        private var
            _grid:Grid3,
            _autoHide:Boolean,
            _progress:Progress;
        
        /**
         * @param   grid3       ゲージとなるグラフィックリソース
         * @param   size        ゲージの長さ
         */
        public function Gauge(grid3:Grid3, size:Number, autoHide:Boolean = true)
        {
            _grid = grid3;
            
            _autoHide = autoHide;
            
            _progress = new Progress();
            _progress.enabledRound = true;
            _progress.setRange(grid3.headSize, size - grid3.tailSize);
        }
        
        public function destroy():void
        {
            _grid = null;
        }
        
        public function update(percentage:Number):void
        {
            _progress.updateByRate(percentage);
            
            if (_autoHide)
                _grid.visible = 0 < percentage;
            
            _grid.size = _progress.now + _grid.tailSize;
        }
    }
}