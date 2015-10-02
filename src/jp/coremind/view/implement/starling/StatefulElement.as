package jp.coremind.view.implement.starling
{
    import jp.coremind.model.module.StatusModel;
    import jp.coremind.model.module.StatusModelConfigure;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.interaction.StatefulElementInteractionListener;
    import jp.coremind.view.layout.LayoutCalculator;
    
    /**
     * Elementクラスに状態機能を加えたクラス.
     */
    public class StatefulElement extends Element
    {
        protected function get _statusModelConfigureKey():Class { return StatefulElement }
        
        StatusModelConfigure.registry(StatefulElement, []);
        
        public function StatefulElement(
            layoutCalculator:LayoutCalculator,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
        }
        
        override protected function _initializeElementModel():void
        {
            super._initializeElementModel();
            
            if (_elementModel.isUndefined(StatusModel))
                _elementModel.addModule(StatusModel.create(_statusModelConfigureKey));
            
            _elementModel.getModule(StatusModel).addListener(_applyStatus);
            _elementModel.getModule(StatusModel).addListener(_applyResouce);
        }
        
        override protected function _onLoadStorageReader(id:String):void
        {
            super._onLoadStorageReader(id);
            
            _initializeStatus();
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
            StatefulElementInteractionListener
                .request($.getClassByInstance(this))
                .apply(group, status, this);
        }
        
        override public function reset():void
        {
            if (_reader)
            {
                _elementModel.getModule(StatusModel).removeListener(_applyStatus);
                _elementModel.getModule(StatusModel).removeListener(_applyResouce);
            }
            
            super.reset();
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            if (_reader)
            {
                _elementModel.getModule(StatusModel).removeListener(_applyStatus);
                _elementModel.getModule(StatusModel).removeListener(_applyResouce);
            }
            
            super.destroy(withReference);
        }
    }
}