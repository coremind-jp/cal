package jp.coremind.view.implement.starling
{
    import jp.coremind.model.ElementModelAccessor;
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.StatusModelConfigure;
    import jp.coremind.utility.Log;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.LayoutCalculator;
    import jp.coremind.view.parts.StatefulElementResourcePack;
    
    /**
     * Elementクラスに状態機能を加えたクラス.
     */
    public class StatefulElement extends Element
    {
        protected function get _statusModelConfigureKey():Class { return StatefulElement }
        
        StatusModelConfigure.registry(StatefulElement, []);
        
        protected var _resourcePack:StatefulElementResourcePack;
        
        public function StatefulElement(
            layoutCalculator:LayoutCalculator,
            controllerClass:Class = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, controllerClass, backgroundBuilder);
            
            _resourcePack = new StatefulElementResourcePack();
        }
        
        override public function initialize(storageId:String = null):void
        {
            super.initialize(storageId);
            
            if (_reader)
            {
                var ema:ElementModelAccessor = _reader.getElementModelAccessor(_elementId);
                ema.addListener(StatusModel, _applyStatus);
                ema.addListener(StatusModel, _applyResouce);
                //_initializeStatus();
            }
        }
        
        override public function initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            super.initializeElementSize(actualParentWidth, actualParentHeight);
            
            _initializeStatus();
            
            var a:Array = [];
            for (var k:int = 0; k < numChildren; k++) 
                a.push(getChildAt(k).name, getChildAt(k).width, getChildAt(k).height);
            Log.info("Element Initialized!", a.join(","));
        }
        
        override protected function _initializeRuntimeModel():void
        {
            var ema:ElementModelAccessor = _reader.getElementModelAccessor(_elementId);
            if (ema.isUndefined(StatusModel)) ema.addModel(StatusModel.create(_statusModelConfigureKey));
        }
        
        /**
         * ステータスを初期化する.
         */
        protected function _initializeStatus():void {}
        
        /**
         * 現在のStatusModelオブジェクトのハンドリングメソッド.
         */
        protected function _applyStatus(group:String, status:String):Boolean
        {
            return false;
        }
        
        private function _applyResouce(group:String, status:String):void
        {
            _resourcePack.apply(group, status, this);
        }
        
        override public function reset():void
        {
            if (_reader)
            {
                var ema:ElementModelAccessor = _reader.getElementModelAccessor(_elementId);
                ema.removeListener(StatusModel, _applyStatus);
                ema.removeListener(StatusModel, _applyResouce);
            }
            
            super.reset();
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            if (_reader)
            {
                var ema:ElementModelAccessor = _reader.getElementModelAccessor(_elementId);
                ema.removeListener(StatusModel, _applyStatus);
                ema.removeListener(StatusModel, _applyResouce);
            }
            
            super.destroy(withReference);
        }
    }
}