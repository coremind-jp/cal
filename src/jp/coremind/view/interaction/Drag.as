package jp.coremind.view.interaction
{
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.utility.data.NumberTracker;
    
    import starling.core.Starling;
    
    /**
     * ドラッグの座標計算を行うクラス.
     * ドラッグ領域をステージ座標で割り出し、flash.display.Stageで取得できるmouseX, mouseYで移動量を計算することを留意。
     */
    public class Drag
    {
        protected var
            _ignorePointerDevice:Boolean,
            _running:Boolean,
            _adsorbThreshold:Number,
            _dragListener:Function,
            _dropListener:Function,
            _trackX:NumberTracker,
            _trackY:NumberTracker;
        
        /**
         * @param   adsorbThreshold 吸着閾値。この閾値以下の場合、ドラッグは発生しない。
         */
        public function Drag(adsorbThreshold:Number = 10)
        {
            _ignorePointerDevice = false;
            _running = false;
            _adsorbThreshold = Math.abs(adsorbThreshold * Starling.contentScaleFactor);
        }
        
        public function get running():Boolean
        {
            return _running;
        }
        
        public function ignorePointerDevice(boolean:Boolean):void
        {
            _ignorePointerDevice = ignorePointerDevice;
            if (_ignorePointerDevice && _running) _onUp();
        }
        
        public function destory():void
        {
            Application.stage.removeEventListener(MouseEvent.MOUSE_UP, _onUp);
            
            _running = false;
            _dragListener = _dropListener = null;
            _trackX = _trackY = null;
        }
        
        /**
         * ドラッグを開始する.
         * メソッド呼出し後にドロップするまでdragListenerパラメータへ計算結果(x, yそれぞれを監視したNumberTrackerオブジェクト)を渡して呼び出す。
         * 呼び出し側ではこの引数を元にドラッグ対象となっている表示オブジェクトの座標更新を行う。
         * 
         * パラメータdropListenerを引数に与えていた場合、ドロップした時にこの関数を呼び出す。
         * 関数へ渡す引数はdragListenerと同様。
         * @param   offset          コンテナのローカル座標上のポインタの位置とコンテナの縦・横を格納するRectangleオブジェクト
         * @param   dragArea        ステージ座標上のドラッグ領域を格納するRectangleオブジェクト
         * @param   dragListener    ドラッグを開始してからドロップするまでフレーム更新毎に呼ばれる関数
         * @param   drupListener    ドロップした際に呼ばれる関数
         */
        public function initialize(offset:Rectangle, dragArea:Rectangle, dragListener:Function, dropListener:Function = null):void
        {
            if (_running) return;
            
            _running = true;
            _dragListener = dragListener;
            _dropListener = dropListener;
            
            createTracker(offset, dragArea);
        }
        
        public function beginPointerDeviceListening():void
        {
            if (_ignorePointerDevice) return;
            
            $.loop.juggler.setInterval(_onUpdate);
            Application.stage.addEventListener(MouseEvent.MOUSE_UP, _onUp);
        }
        
        public function moveTo(x:Number, y:Number):void
        {
            _update(Application.pointerX + x, Application.pointerY + y);
        }
        
        public function drop():void
        {
            _onUp();
        }
        
        /**
         * コンテナとドラッグ対象との現在の距離情報を求めるためのオブジェクトを生成する.
         * このメソッドの用途はドラッグの開始をせずに状態データを取得するのが目的。
         * ※observeメソッドのdragListener, dropListenerへ渡されるNumberTrackerオブジェクトを利用した表示オブジェクトの更新が必要な場合等
         * 
         * @param   offset      コンテナのローカル座標上のポインタの位置とコンテナの縦・横を格納するRectangleオブジェクト
         * @param   dragArea    ステージ座標上のドラッグ領域を格納するRectangleオブジェクト
         * @param   callback    生成された現在の距離情報(NumberTrackerオブジェクト)の渡し先となる関数
         */
        public function createTracker(offset:Rectangle, dragArea:Rectangle, callback:Function = null):void
        {
            _createTracker(offset, dragArea);
            
            _trackX.initialize(Application.pointerX);
            _trackY.initialize(Application.pointerY);
            
            if (callback is Function) callback(_trackX, _trackY);
        }
        
        /**
         * 座標計測用オブジェクトを生成しドラッグ領域を確定する.
         * @param   offset      コンテナのローカル座標上のポインタの位置とコンテナの縦・横を格納するRectangleオブジェクト
         * @param   dragArea    ステージ座標上のドラッグ領域を格納するRectangleオブジェクト
         */
        protected function _createTracker(offset:Rectangle, dragArea:Rectangle):void
        {
            _trackX = new NumberTracker();
            _trackX.setRange(dragArea.left + offset.x, dragArea.right - offset.width + offset.x, false);
            
            _trackY = new NumberTracker();
            _trackY.setRange(dragArea.top + offset.y, dragArea.bottom - offset.height + offset.y, false);
        }
        
        protected function _onUpdate(elapsed:int):Boolean
        {
            return _update(Application.pointerX, Application.pointerY);
        }
        
        /**
         * 座標更新を行う.
         */
        private function _update(x:Number, y:Number):Boolean
        {
            if (!_running) return true;
            
            var w:int = Application.configure.appViewPort.width;
            var h:int = Application.configure.appViewPort.height;
            x = _applyOutOfRangeResistance(x, _trackX, w);
            y = _applyOutOfRangeResistance(y, _trackY, h);
            /*
            if (_isAdsorb(_trackX.start - x, _trackY.start - y))
            {
                x = _trackX.start;
                y = _trackY.start;
            }
            */
            var changedX:Boolean = _trackX.update(x);
            var changedY:Boolean = _trackY.update(y);
            if (changedX || changedY) _dragListener(_trackX, _trackY);
            
            return false;
        }
        
        /**
         * パラメータx, yが吸着領域内に含まれているかを示す値を返す.
         */
        private function _isAdsorb(x:Number, y:Number):Boolean
        {
            return -_adsorbThreshold < x && x < _adsorbThreshold
                && -_adsorbThreshold < y && y < _adsorbThreshold;
        }
        
        /**
         * パラメータnがドラック領域外に存在する場合に抵抗力を適応した値を返す.
         */
        private function _applyOutOfRangeResistance(n:Number, v:NumberTracker, resistence:Number):Number
        {
            var overflow:Number;
            
            if (n < v.min)
            {
                overflow = v.min - n;
                return v.min - (resistence < overflow ? resistence>>1: overflow>>1);
            }
            else
            if (v.max < n)
            {
                overflow = n - v.max;
                return v.max + (resistence < overflow ? resistence>>1: overflow>>1);
            }
            else
                return n;
        }
        
        protected function _onUp(e:MouseEvent = null):void
        {
            if (_dropListener is Function)
                _dropListener(_trackX, _trackY);
            
            destory();
        }
    }
}