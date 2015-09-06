package jp.coremind.view.abstract.component
{
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IStretchBox;

    /**
     * Grid3クラスを応用した9Grid表現クラス.
     */
    public class Grid9 implements IStretchBox
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
            _top     = new Grid3X();
            _vCenter = new Grid3X();
            _bottom  = new Grid3X();
            
            _left    = new Grid3Y();
            _hCenter = new Grid3Y();
            _right   = new Grid3Y();
        }
        
        public function destroy():void
        {
            _top.destroy();
            _vCenter.destroy();
            _bottom.destroy();
            
            _left.destroy();
            _hCenter.destroy();
            _right.destroy();
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
        public function setResource(
            parent:IDisplayObject,
            topLeft:IDisplayObject,    top:IDisplayObject,    topRight:IDisplayObject,
            left:IDisplayObject,       body:IDisplayObject,   right:IDisplayObject,
            bottomLeft:IDisplayObject, bottom:IDisplayObject, bottomRight:IDisplayObject):void
        {
                _top.setResource(parent,    topLeft,    top,    topRight);
            _vCenter.setResource(parent,       left,   body,       right);
             _bottom.setResource(parent, bottomLeft, bottom, bottomRight);
            
               _left.setResource(parent,    topLeft,   left,  bottomLeft);
            _hCenter.setResource(parent,        top,   body,      bottom);
              _right.setResource(parent,   topRight,  right, bottomRight);
        }
        
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