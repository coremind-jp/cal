package jp.coremind.view.builder
{
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.model.transaction.ListDiff;
    import jp.coremind.storage.ModelReader;
    
    /**
     */
    public class GridListElementFactory extends ListElementFactory
    {
        private var
            _densityList:Vector.<int>;
        
        public function GridListElementFactory()
        {
            _densityList = new <int>[];
        }
        
        override public function destroy():void
        {
            _densityList.length = 0;
            
            super.destroy();
        }
        
        override public function initialize(reader:ModelReader):void
        {
            super.initialize(reader);
            
            var dataList:Array = _reader.read();
            
            _densityList.length = 0;
            for (var i:int = 0, len:int = dataList.length; i < len; i++) 
                _pushDensity(_densityList, dataList[i], i, len);
        }
        
        override public function preview(plainDiff:Diff):void
        {
            var diff:ListDiff = plainDiff as ListDiff;
            var dataList:Array = diff.editedOrigin;
            
            _densityList.length = 0;
            
            if (diff.order)
                for (var i:int = 0, iLen:int = diff.order.length; i < iLen; i++)
                    _pushDensity(_densityList, dataList[ diff.order[i] ], i, iLen);
            else
                for (var j:int = 0, jLen:int = dataList.length; i < jLen; i++)
                    _pushDensity(_densityList, dataList[i], i, jLen);
        }
        
        /**
         * グリッド密度リストを返す.
         */
        public function get densityList():Vector.<int>
        {
            return _densityList;
        }
        
        protected function _pushDensity(densityList:Vector.<int>, modelData:*, index:int, length:int):void
        {
            densityList.push(1, 1);
        }
    }
}