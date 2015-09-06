package jp.coremind.view.layout
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Application;
    
    public class LayoutSimulation
    {
        private var
            _children:Dictionary,
            _drawableArea:Point,
            _hitbox:Rectangle,
            
            _contains:Dictionary,
            
            _add:Dictionary,
            _move:Dictionary,
            _remove:Dictionary;
            
        /**
         * 描画領域を定義し、データとRectangleを紐付け、それらが交わったか(描画対象可否)を判定するクラス.
         * リスト長が膨大で描画インスタンスを一度に生成できない場合に利用し実体として生成するインスタンスを一定数に抑えるのが目的。
         */
        public function LayoutSimulation()
        {
            _contains     = new Dictionary(true);
            _children     = new Dictionary(true);
            _drawableArea = new Point(Application.VIEW_PORT.width, Application.VIEW_PORT.height);
            _hitbox       = new Rectangle(Number.MAX_VALUE, Number.MAX_VALUE, _drawableArea.x, _drawableArea.y);
        }
        
        public function destroy():void
        {
            var key:*;
            
            for (key in _remove)   delete _remove[key];
            for (key in _move)     delete _move[key];
            for (key in _add)      delete _add[key];
            for (key in _contains) delete _contains[key];
            for (key in _children) delete _children[key];
        }
        
        /**
         * このコンテナの描画領域を定義する.
         * @param width    描画領域の横幅
         * @param height   描画領域の縦幅
         */
        public function setDrawableArea(width:Number, height:Number):void
        {
            _hitbox.width  = width;
            _hitbox.height = height;
        }
        
        /**
         * 現在描画対象となるデータをキーとしたRectangleリストを返す.
         */
        public function get contains():Dictionary { return _contains; }
        
        /**
         * 直前のrefreshの呼び出し結果と比較して新たに描画対象となるデータをキーとしたRectangleリストを返す.
         */
        public function get added():Dictionary    { return _add;      }
        
        /**
         * 直前のrefreshの呼び出し結果と比較して描画対象の移動が必要なデータをキーとしたRectangleリストを返す.
         */
        public function get moved():Dictionary    { return _move;     }
        
        /**
         * 直前のrefreshの呼び出し結果と比較して描画対象から外す必要があるデータをキーとしたRectangleリストを返す.
         */
        public function get removed():Dictionary  { return _remove;   }
        
        /**
         * 子を追加する.
         * @param  key パラメータRectangleに紐付けるデータ(プリミティブ型の指定は不可)
         * @param  rect    このデータの描画領域を定義したRectangle
         */
        public function addChild(key:*, rect:Rectangle):void
        {
            _children[key] = rect;
        }
        
        /**
         * keyパラメータに紐づくRectangleを削除する.
         */
        public function removechild(key:*):void
        {
            delete _children[key];
        }
        
        /**
         * keyパラメータに紐づくRectangleを取得する.
         */
        public function getChild(key:*):Rectangle
        {
            return _children[key];
        }
        
        /**
         * 描画領域の基準点を変更しパラメータx, yを基点とした描画領域に当てはまるデータを割り出す.
         * このメソッドを呼び出した後にadded, moved, removed, containsが取得可能となる。
         * @param  x   描画領域基準点x
         * @param  y   描画領域基準点y
         */
        public function refresh(x:Number, y:Number):void
        {
            _hitbox.x = -x;
            _hitbox.y = -y;
            
            var before:Dictionary = _contains;
            _contains = new Dictionary(true);
            _add      = new Dictionary(true);
            _move     = new Dictionary(true);
            
            for (var key:* in _children)
            {
                var rect:Rectangle = _children[key];
                
                //Log.info(rect);
                if (_hitbox.intersects(rect))
                {
                    //Log.info("intersects");
                    _contains[key] = rect;
                    
                    key in before ? _move[key] = rect: _add[key] = rect;
                    
                    delete before[key];
                }
            }
            
            _remove = before;
        }
    }
}