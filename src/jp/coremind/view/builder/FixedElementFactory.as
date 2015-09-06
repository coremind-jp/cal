package jp.coremind.view.builder
{
    import jp.coremind.core.Application;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    
    /**
     * ListContainerで生成する子表示オブジェクトがリスト内で単一の場合に利用するクラス.
     */
    public class FixedElementFactory extends GridListElementFactory
    {
        private var
            _builder:ElementBuilder,
            _horizontalDensity:int,
            _verticalDensity:int;
        
        public function FixedElementFactory(elementBuilderName:String, horizontalDensity = 1, verticalDensity = 1)
        {
            _builder = Application.elementBluePrint.createBuilder(elementBuilderName) as ElementBuilder;
            Log.info("new FixedElementFactory", elementBuilderName, _builder);
            _horizontalDensity = horizontalDensity;
            _verticalDensity   = verticalDensity;
        }
        
        /**
         * データに紐付くエレメントを取得する.
         * 存在しない場合、暗黙的に新たにエレメントインスタンスが生成される。
         */
        override public function request(actualParentWidth:int, actualParentHeight:int, modelData:*, index:int = -1, length:int = -1):IElement
        {
            if (hasElement(modelData))
                return _createdInstance[modelData];
            
            var r:IRecycle = _pool.request(_builder.elementClass);
            
            var l:Array = _reader.read();
            if (length == -1) length = l.length;
            
            var n:int = l.indexOf(modelData);
            if (index == -1) index = n == -1 ? length: n;
            
            var e:IElement = _createdInstance[modelData] = r ? r as IElement: _builder.buildForListElement();
            elementInitializer(e, _builder, actualParentWidth, actualParentHeight, modelData, index, length);
            
            return e;
        }
        
        override protected function _pushDensity(densityList:Vector.<int>, modelData:*, index:int, length:int):void
        {
            densityList.push(_horizontalDensity, _verticalDensity);
        }
    }
}