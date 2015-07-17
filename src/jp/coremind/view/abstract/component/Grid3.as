package jp.coremind.view.abstract.component
{
    import jp.coremind.view.abstract.IDisplayObject;

    /**
     * 3つのDisplayObjectをグルーピングして1つのDisplayObjectのようにサイズを操作するクラス.
     */
    public class Grid3
    {
        protected var
            _size:Number,
            _headSize:Number,
            _tailSize:Number,
            
            _parent:IDisplayObject,
            _head:IDisplayObject,
            _body:IDisplayObject,
            _tail:IDisplayObject;
        
        public function Grid3()
        {
            _size = _headSize = _tailSize = 0;
        }
        
        /**
         * 関連付けをする.
         * head, body, tailへ渡したDisplayObjectはprentに含まれておりparentの左上を基準とした制御を想定している。
         * @param   parent  head, body, tailパラメータに渡されるDisplayObjectの親となるDisplayObject
         * @param   head    可変長方向の先頭に配置されるDisplayObject(固定長)
         * @param   body    headとtailの間に配置されるDisplayObject(可変長)
         * @param   tail    可変長方向の末尾に配置されるDisplayObject(固定長)
         */
        public function setResource(parent:IDisplayObject, body:IDisplayObject, head:IDisplayObject, tail:IDisplayObject):void
        {
            _parent = parent;
            _head = head;
            _body = body;
            _tail = tail;
        }
        
        public function destroy():void
        {
            _parent = _head = _body = _tail = null;
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
        /**
         * setResourceメソッドのparentパラメータに渡したDisplayObjectの可視状態を取得する.
         */
        public function set visible(value:Boolean):void
        {
            _parent.visible = value;
        }
        /**
         * setResourceメソッドのparentパラメータに渡したDisplayObjectの可視状態を設定する.
         */
        public function get visible():Boolean
        {
            return _parent.visible;
        }
    }
}