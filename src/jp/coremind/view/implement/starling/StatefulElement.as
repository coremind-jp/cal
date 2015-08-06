package jp.coremind.view.implement.starling
{
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.StatusModelConfigure;
    import jp.coremind.model.StorageModelReader;
    
    /**
     * Elementクラスに状態機能を加えたクラス.
     */
    public class StatefulElement extends Element
    {
        protected function get _statusModelConfigureKey():Class { return StatefulElement }
        
        StatusModelConfigure.registry(StatefulElement, []);
        
        public function StatefulElement()
        {
        }
        
        override public function initialize(reader:StorageModelReader):void
        {
            super.initialize(reader);
            
            if (_reader)
            {
                _reader.runtime.addListener(StatusModel, _applyStatus);
                _initializeStatus();
            }
        }
        
        override protected function _initializeRuntimeModel():void
        {
            if (_reader.runtime.isUndefined(StatusModel))
                _reader.runtime.addModel(StatusModel, StatusModel.create(_statusModelConfigureKey));
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
        
        override public function reset():void
        {
            if (_reader)
                _reader.runtime.removeListener(StatusModel, _applyStatus);
            
            super.reset();
        }
        
        override public function destroy():void
        {
            if (_reader)
                _reader.runtime.removeListener(StatusModel, _applyStatus);
            
            super.destroy();
        }
    }
}