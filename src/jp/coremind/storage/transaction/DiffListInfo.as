package jp.coremind.storage.transaction
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    public class DiffListInfo
    {
        public static const TAG:String = "[DiffListInfo]";
        Log.addCustomTag(TAG);
        
        internal var
            _order:Vector.<int>,
            _removed:Dictionary,
            _removeRestored:Dictionary,
            _filtered:Dictionary,
            _filterRestored:Dictionary;
        
        public function DiffListInfo()
        {
            _removed = new Dictionary(true);
        }
        
        /**
         * 元データにソート関数を実行した結果(ソート後のindex配列)を返す.
         */
        public   function get order():Vector.<int>          { return _order; }
        internal function setOrder(list:Vector.<int>):void  { _order = list; }
        
        /**
         * 元データと比較してフィルタリングされたデータのリストを返す.
         */
        public function get filtered():Dictionary { return _filtered; }
        internal function setFiltered(filtered:Dictionary):void { _filtered = filtered; }
        
        /**
         * 直前の差分と比較してフィルタリングが解除されたデータのリストを返す.
         */
        public function get filterRestored():Dictionary { return _filterRestored; }
        internal function setFilterRestored(restored:Dictionary):void { _filterRestored = restored; }
        
        /**
         * 元データと比較して取り除かれたデータのリストを返す.
         */
        public function get removed():Dictionary { return _removed; }
        internal function setRemoved(removed:Dictionary):void { _removed = removed; }
        
        /**
         * 直前の差分と比較して削除が復元されたデータのリストを返す.
         */
        public function get removeRestored():Dictionary { return _removeRestored; }
        internal function setRemoveRestored(restored:Dictionary):void { _removeRestored = restored; }
        
        public function toString():String
        {
            var p:*;
            
            var numRestored:int = 0;
            for (p in _filterRestored) numRestored++;
            
            var numFiltered:int = 0;
            for (p in _filtered) numFiltered++;
            
            var numRemoved:int = 0;
            for (p in _removed) numRemoved++;
            
            return TAG
                + " numRestored:" + numRestored
                + " numFiltered:" + numFiltered
                + " numRemoved:"  + numRemoved
                + " order:"       +(order ? order.toString(): "null");
        }
    }
}