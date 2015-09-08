package jp.coremind.view.abstract.component
{
    import flash.geom.Point;
    
    import jp.coremind.asset.GridAsset;
    import jp.coremind.view.abstract.IDisplayObject;

    /**
     * 3つのDisplayObjectをグルーピングして1つのDisplayObjectのようにサイズを操作するクラス.
     */
    public class Grid3
    {
        private static const _POINT:Point = new Point();
        
        protected var
            _size:Number,
            _headSize:Number,
            _tailSize:Number,
            _headIndex:int,
            _bodyIndex:int,
            _tailIndex:int,
            _asset:GridAsset;
        
        public function Grid3()
        {
            _size = _headSize = _tailSize = 0;
        }
        
        protected function get _head():IDisplayObject { return _asset.getChildAt(_headIndex) as IDisplayObject; }
        protected function get _body():IDisplayObject { return _asset.getChildAt(_bodyIndex) as IDisplayObject; }
        protected function get _tail():IDisplayObject { return _asset.getChildAt(_tailIndex) as IDisplayObject; }
        
        /**
         * 関連付けをする.
         * head, body, tailへ渡したDisplayObjectはprentに含まれておりparentの左上を基準とした制御を想定している。
         * @param   parent  head, body, tailパラメータに渡されるDisplayObjectの親となるDisplayObject
         * @param   head    可変長方向の先頭に配置されるDisplayObject(固定長)
         * @param   body    headとtailの間に配置されるDisplayObject(可変長)
         * @param   tail    可変長方向の末尾に配置されるDisplayObject(固定長)
         */
        public function setAsset(asset:GridAsset):Grid3
        {
            _asset = asset;
            
            return this;
        }
        
        public function destroy(withReference:Boolean = true):void
        {
            _asset = null;
        }
        
        /**
         * このオブジェクトの可変長方向のサイズを取得する.
         */
        public function get size():Number { return _size; }
        /**
         * このオブジェクトの可変長方向のサイズを設定する.
         */
        public function set size(value:Number):void {}
        /**
         * このオブジェクトの可変長方向の初期座標を取得する.
         */
        public function get position():Number { return 0; }
        /**
         * このオブジェクトの可変長方向の初期座標を設定する.
         */
        public function set position(value:Number):void {}
        
        /**
         * setResourceメソッドのbodyパラメータに渡したDisplayObjectのサイズを取得する.
         */
        public function get bodySize():Number { return _size - _headSize - _tailSize; }
        /**
         * setResourceメソッドのheadパラメータに渡したDisplayObjectのサイズを取得する.
         */
        public function get headSize():Number { return _headSize; }
        /**
         * setResourceメソッドのtailパラメータに渡したDisplayObjectのサイズを取得する.
         */
        public function get tailSize():Number { return _tailSize; }
        
        public function get asset():IDisplayObject
        {
            return _asset;
        }
    }
}