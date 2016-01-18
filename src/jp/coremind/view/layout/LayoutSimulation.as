package jp.coremind.view.layout
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Application;
    import jp.coremind.utility.Log;
    
    public class LayoutSimulation
    {
        public static const TAG:String = "[LayoutSimulation]";
        Log.addCustomTag(TAG);
        
        private static const _EMPTY:Dictionary = new Dictionary(true);
        
        private var
            _drawableArea:Point,
            _hitbox:Rectangle,
            
            _master:Dictionary,
            _hidden:Dictionary,
            _create:Dictionary,
            _invisible:Dictionary,
            _visible:Dictionary,
            _preventVisible:Dictionary,
            _preventPosition:Dictionary;
            
        /**
         * 描画領域を定義し、データとRectangleを紐付け、それらが交わったか(描画対象可否)を判定するクラス.
         * リスト長が膨大で描画インスタンスを一度に生成できない場合に利用し実体として生成するインスタンスを一定数に抑えるのが目的。
         */
        public function LayoutSimulation()
        {
            var w:int = Application.configure.appViewPort.width;
            var h:int = Application.configure.appViewPort.height;
            
            _drawableArea = new Point(w, h);
            _hitbox       = new Rectangle(Number.MAX_VALUE, Number.MAX_VALUE, _drawableArea.x, _drawableArea.y);
            
            _master       = new Dictionary(true);
            _hidden       = new Dictionary(true);
        }
        
        public function destroy():void
        {
            _master          = reset(_master);
            _hidden          = reset(_hidden);
            _create          = reset(_create);
            _invisible       = reset(_invisible);
            _visible         = reset(_visible);
            _preventVisible  = reset(_preventVisible);
            _preventPosition = reset(_preventPosition);
        }
        
        private function reset(dic:Dictionary):*
        {
            for (var key:* in dic) delete dic[key];
            return null;
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
        
        public function hideChild(key:*):void { _hidden[key] = true; }
        public function showChild(key:*):void { delete _hidden[key]; }
        
//master
        /**
         * 子を追加する.
         * @param  key パラメータRectangleに紐付けるデータ(プリミティブ型の指定は不可)
         * @param  rect    このデータの描画領域を定義したRectangle
         */
        public function addChild(key:*, rect:Rectangle):void
        {
            _master[key] = rect;
        }
        
        /**
         * keyパラメータに紐づくRectangleを削除する.
         */
        public function removeChild(key:*):void
        {
            delete _master[key];
        }
        
        public function hasChild(key:*):Boolean
        {
            return key in _master;
        }
        
        /**
         * keyパラメータに紐づくRectangleを取得する.
         */
        public function findChild(key:*):Rectangle
        {
            return _master[key];
        }
//master
        
        /**
         * 内部の状態を破棄する.
         * updateChildPositionメソッド利用する前に呼び出す必要がある。
         */
        public function beginChildPositionEdit():void
        {
            _invisible = _visible = _create = _EMPTY;
            _preventPosition = new Dictionary(true);
        }
        
        /**
         * 追加済みの子のRectangleを更新する.
         * このメソッドを利用する前にclearメソッドを呼び出す必要がある。
         */
        public function updateChildPosition(key:*, rect:Rectangle):void
        {
            var child:Rectangle = _master[key];
            if (child && (child.x != rect.x || child.y != rect.y))
            {
                _preventPosition[key] = child.clone();
                child.setTo(rect.x, rect.y, rect.width, rect.height);
                Log.custom(TAG, "update", key, rect);
            }
        }
        
        /**
         * 描画領域の基準点をパラメータx, yへ変更し描画領域に当てはまる子リストを更新する.
         * このメソッドを利用する前にclearメソッドを呼び出す必要がある。
         * @param  x   描画領域基準点x
         * @param  y   描画領域基準点y
         */
        public function updateContainerPosition(x:Number, y:Number):void
        {
            _hitbox.x = -x;
            _hitbox.y = -y;
            
            //直前に行われたupdateContainerPositionの結果(_preventVisible)から
            //この処理で判定に入った子を除外していけば結果的に残ったものが削除すべき対象(_invisible)となる
            _invisible = _preventVisible || _EMPTY;
            _visible   = new Dictionary(true);
            _create    = new Dictionary(true);
            if (!_preventPosition) _preventPosition = _EMPTY;
            
            for (var key:* in _master)
            {
                var child:Rectangle = _master[key];
                
                if (!(key in _hidden) && _hitbox.intersects(child))
                {
                    _visible[key] = true;
                    
                    key in _invisible ? delete _invisible[key]: _create[key] = true;
                }
            }
            
            _preventVisible = _visible;
        }
        
        public function endChildPositionEdit():void
        {
            _preventPosition = _EMPTY;
        }
        
        /**
         * 直前のrefreshの呼び出し結果と比較して新たに描画対象となるデータをキーとしたRectangleリストを返す.
         */
        public function switchClosure(key:*, createClosure:Function, visibleClosure:Function, invisibleClosure:Function):void
        {
                 if (key in _create)                              createClosure(key, _master[key], _preventPosition[key]);
            else if (key in _visible && key in _preventPosition) visibleClosure(key, _master[key], _preventPosition[key]);
            else if (key in _invisible)                        invisibleClosure(key, _master[key], _preventPosition[key]);
        }
        
        /**
         * 現在保持されている表示対象となる子リストに対して関数fを実行する.
         */
        public function eachVisible(f:Function):void
        {
            for (var p:* in _visible) f(p, _master[p], _preventPosition[p]);
        }
        
        /**
         * 現在保持されている非表示対象となる子リストに対して関数fを実行する.
         */
        public function eachInvisible(f:Function):void
        {
            for (var p:* in _invisible) f(p, _master[p], _preventPosition[p]);
        }
        
        public function toString():String
        {
            var p:*;
            
            var numChildren:int = 0;
            for (p in _master) numChildren++;
            
            var numVisible:int = 0;
            for (p in _visible) numVisible++;
            
            var numInvisible:int = 0;
            for (p in _invisible) numInvisible++;
            
            var numPrev:int = 0;
            for (p in _preventPosition) numPrev++;
            
            return TAG
                + " numChildren:"    + numChildren
                + " numVisible:"     + numVisible
                + " numInvisible:"   + numInvisible
                + " numPrev:"        + numPrev;
        }
    }
}