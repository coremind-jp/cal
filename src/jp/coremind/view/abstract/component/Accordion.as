package jp.coremind.view.abstract.component
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;

    /**
     * 任意の数のIBoxインターフェースを実装したObjectをこのオブジェクトのサイズに合わせてリサイズするクラス.
     */
    public class Accordion
    {
        private var
            _size:Number,
            _total:Number,
            _boxList:Vector.<IBox>,
            _ratioList:Vector.<Number>;
        
        public function Accordion()
        {
            _size      = 0;
            _total     = 0;
            _boxList  = new <IBox>[];
            _ratioList = new <Number>[];
        }
        
        public function destroy():void
        {
            _boxList.length = _ratioList.length = 0;
        }
        
        /**
         * 先頭に子を追加する.
         * 内部では追加された全ての子のratioパラメータの合計から比率を割り出すためratioパラメータに渡す値は負の値でなければ基本的に制限は無い。
         * このメソッドの呼出し後はupdateを呼び出さなければ更新されない。
         * @param   child   追加する子IBoxインターフェースを実装したObject
         * @param   ratio   childパラメータで指定した子IBoxインターフェースを実装したObjectのこのオブジェクトでの占有率
         */
        public function unshift(child:IBox, ratio:Number):Accordion
        {
            if (ratio < 0) ratio = 0;
            
            _total += ratio;
            _boxList.unshift(child);
            _ratioList.unshift(ratio);
            
            return this;
        }
        
        /**
         * 末尾に子を追加する.
         * 内部では追加された全ての子のratioパラメータの合計から比率を割り出すためratioパラメータに渡す値は負の値でなければ基本的に制限は無い。
         * このメソッドの呼出し後はupdateを呼び出さなければ更新されない。
         * @param   child   追加する子IBoxインターフェースを実装したObject
         * @param   ratio   childパラメータで指定した子IBoxインターフェースを実装したObjectのこのオブジェクトでの占有率
         */
        public function push(child:IBox, ratio:Number):Accordion
        {
            if (ratio < 0) ratio = 0;
            
            _total += ratio;
            _boxList.push(child);
            _ratioList.push(ratio);
            
            return this;
        }
        
        /**
         * 先頭の子を削除する.
         * 内部では追加された全ての子のratioパラメータの合計から比率を割り出すためratioパラメータに渡す値は負の値でなければ基本的に制限は無い。
         * このメソッドの呼出し後はupdateを呼び出さなければ更新されない。
         * @param   child   追加する子IBoxインターフェースを実装したObject
         * @param   ratio   childパラメータで指定した子IBoxインターフェースを実装したObjectのこのオブジェクトでの占有率
         */
        public function shift():Accordion
        {
            if (_boxList.length == 0) return this;
            
            _boxList.shift();
            _total -= _ratioList.shift();
            
            return this;
        }
        
        /**
         * 末尾の子を削除する.
         * 内部では追加された全ての子のratioパラメータの合計から比率を割り出すためratioパラメータに渡す値は負の値でなければ基本的に制限は無い。
         * このメソッドの呼出し後はupdateを呼び出さなければ更新されない。
         * @param   child   追加する子IBoxインターフェースを実装したObject
         * @param   ratio   childパラメータで指定した子IBoxインターフェースを実装したObjectのこのオブジェクトでの占有率
         */
        public function pop():Accordion
        {
            if (_boxList.length == 0) return this;
            
            _boxList.pop();
            _total -= _ratioList.pop();
            
            return this;
        }
        
        /**
         * indexパラメータで指定したインデックスにある子を削除する.
         * indexパラメータが範囲外の場合は何もしない。このメソッドの呼出し後はupdateを呼び出さなければ更新されない。
         */
        public function spliceByIndex(index:int):Accordion
        {
            if (_boxList.length == 0 || index < 0 || _boxList.length <= index) return this;
            
            _boxList.splice(index, 1)[0];
            _total -= _ratioList.splice(index, 1)[0];
            
            return this;
        }
        
        /**
         * childパラメータで指定したIBoxインターフェースを実装したObjectと同一の子を削除する.
         * 見つからない場合は何もしない。このメソッドの呼出し後はupdateを呼び出さなければ更新されない。
         */
        public function spliceByBox(child:IBox):Accordion
        {
            return spliceByIndex(_boxList.indexOf(child));
        }
        
        /**
         * 現在の状態を更新する.
         */
        public function update():void
        {
            var ratio:Number, childSize:Number, childPosition:Number = 0;
            for (var i:int, len:int = _boxList.length; i < len; i++)
            {
                ratio     = _ratioList[i] / _total;
                childSize = (_size * ratio);
                
                _updateBox(_boxList[i], childSize, childPosition);
                
                childPosition += childSize;
            }
        }
        
        /**
         * childパラメータで指定されたIBoxインターフェースを実装したObjectの伸縮方向の座標とサイズを更新する.
         */
        protected function _updateBox(child:IBox, childSize:Number, childPosition:Number):void
        {
            
        }
        
        /**
         * このオブジェクトのサイズを取得する.
         */
        public function get size():Number
        {
            return _size;
        }
        /**
         * このオブジェクトのサイズを設定する.
         */
        public function set size(value:Number):void
        {
            _size = value;
            update();
        }
    }
}