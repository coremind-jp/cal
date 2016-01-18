package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.core.StatusModelType;
    import jp.coremind.model.module.StatusModule;
    import jp.coremind.utility.Log;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.interaction.StatefulElementInteraction;
    import jp.coremind.view.layout.Layout;
    
    /**
     * Elementクラスに状態機能を加えたクラス.
     */
    public class StatefulElement extends Element
    {
        private var _interactionId:String;
        
        public function StatefulElement(layoutCalculator:Layout, backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
        }
        
        protected function get statusModelType():String
        {
            return StatusModelType.STATEFUL_ELEMENT;
        }
        
        public function get interactionId():String
        {
            return _interactionId;
        }
        
        public function set interactionId(id:String):void
        {
            _interactionId = id;
        }
        
        override protected function _initializeModules():void
        {
            super._initializeModules();
            
            if (_info.modules.isUndefined(StatusModule))
                _info.modules.addModule(new StatusModule(statusModelType))
            
            _info.modules.getModule(StatusModule).addListener(_applyStatus);
            _info.modules.getModule(StatusModule).addListener(_applyInteraction);
            
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
        
        private function _applyInteraction(group:String, status:String):void
        {
            var interaction:StatefulElementInteraction = Application.configure.interaction
                .getStatefulElementInteraction(interactionId);
            
            if (interaction) interaction.apply(this, group, status);
        }
        
        private var _isReset:Boolean = false;
        override public function reset():void
        {
            _isReset = true;
            Log.info(name, _info.modules.dump());
            
            if (_reader)
            {
                _info.modules.getModule(StatusModule).removeListener(_applyStatus);
                _info.modules.getModule(StatusModule).removeListener(_applyInteraction);
            }
            
            super.reset();
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            if (_reader && !_info.modules.isUndefined(StatusModule))
            {
                _info.modules.getModule(StatusModule).removeListener(_applyStatus);
                _info.modules.getModule(StatusModule).removeListener(_applyInteraction);
            }
            
            super.destroy(withReference);
        }
    }
}