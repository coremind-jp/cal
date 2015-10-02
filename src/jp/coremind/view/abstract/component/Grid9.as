package jp.coremind.view.abstract.component
{
    import jp.coremind.asset.GridAsset;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IStretchBox;

    /**
     * Grid3クラスを応用した9Grid表現クラス.
     */
    public class Grid9 implements IStretchBox, IBox
    {
        private var
            _top:Grid3X,
            _vCenter:Grid3X,
            _bottom:Grid3X,
            
            _left:Grid3Y,
            _hCenter:Grid3Y,
            _right:Grid3Y
        
        public function Grid9()
        {
            _top     = new Grid3X(GridAsset.GRID9_LINE_HEAD);
            _vCenter = new Grid3X(GridAsset.GRID9_LINE_BODY);
            _bottom  = new Grid3X(GridAsset.GRID9_LINE_TAIL);
            
            _left    = new Grid3Y(GridAsset.GRID9_LINE_HEAD);
            _hCenter = new Grid3Y(GridAsset.GRID9_LINE_BODY);
            _right   = new Grid3Y(GridAsset.GRID9_LINE_TAIL);
        }
        
        public function destroy(withReference:Boolean = false):void
        {
            if (withReference)
            {
                _top.destroy(withReference);
                _vCenter.destroy(withReference);
                _bottom.destroy(withReference);
                
                _left.destroy(withReference);
                _hCenter.destroy(withReference);
                _right.destroy(withReference);
            }
            
            _top = _vCenter = _bottom = null;
            _left = _hCenter = _right = null;
        }
        
        /**
         * 関連付けをする.
         * parentパラメータ以外のパラメータへ渡したDisplayObjectはprentに含まれておりparentの左上を基準とした制御を想定している。
         * @param   parent  head, body, tailパラメータに渡されるDisplayObjectの親となるDisplayObject
         * @param   topLeft     左上に配置されるDisplayObject(固定長)
         * @param   top         上に配置されるDisplayObject(可変長)
         * @param   topRight    右上に配置されるDisplayObject(固定長)
         * @param   left        左に配置されるDisplayObject(可変長)
         * @param   body        中心に配置されるDisplayObject(可変長)
         * @param   right       右に配置されるDisplayObject(可変長)
         * @param   bottomLeft  左下に配置されるDisplayObject(固定長)
         * @param   bottom      下に配置されるDisplayObject(可変長)
         * @param   bottomRight 右下に配置されるDisplayObject(固定長)
         */
        public function setAsset(asset:GridAsset):Grid9
        {
                _top.setAsset(asset);
            _vCenter.setAsset(asset);
             _bottom.setAsset(asset);
            
               _left.setAsset(asset);
            _hCenter.setAsset(asset);
              _right.setAsset(asset);
              
            return this;
        }
        
        public function get asset():IDisplayObject
        {
            return _top.asset;
        }
        
        public function set x(value:Number):void
        {
            _top.asset.x = value;
        }
        public function get x():Number
        {
            return _top.asset.x;
        }
        
        public function set y(value:Number):void
        {
            _top.asset.y = value;
        }
        public function get y():Number
        {
            return _top.asset.y;
        }
        
        public function set scaleX(value:Number):void {}
        public function get scaleX():Number { return 1; }
        
        public function set scaleY(value:Number):void {}
        public function get scaleY():Number { return 1; }
        
        /**
         * このオブジェクトの高さを設定する.
         */
        public function set height(value:Number):void
        {
            _left.size = _hCenter.size = _right.size = value;
        }
        /**
         * このオブジェクトの高さを取得する.
         */
        public function get height():Number
        {
            return _hCenter.size;
        }
        
        /**
         * このオブジェクトの幅を設定する.
         */
        public function set width(value:Number):void
        {
            _top.size = _vCenter.size = _bottom.size = value;
        }
        /**
         * このオブジェクトの幅を取得する.
         */
        public function get width():Number
        {
            return _vCenter.size;
        }
    }
}