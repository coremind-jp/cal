package jp.coremind.view.builder
{
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.core.Application;
    
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
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            _builder = bluePrint.createBuilder(elementBuilderName) as ElementBuilder;
            _horizontalDensity = horizontalDensity;
            _verticalDensity   = verticalDensity;
        }
        
        override public function destroy():void
        {
            _builder = null;
            
            super.destroy();
        }
        
        override protected function _getBuilder(modelData:*, index:int, length:int):ElementBuilder
        {
            return _builder;
        }
        
        override protected function _pushDensity(densityList:Vector.<int>, modelData:*, index:int, length:int):void
        {
            densityList.push(_horizontalDensity, _verticalDensity);
        }
    }
}