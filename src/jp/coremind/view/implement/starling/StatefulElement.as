package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.core.StatusModelType;
    import jp.coremind.module.StatusModule;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
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
            
            var module:StatusModule;
            if (_info.modules.isUndefined(StatusModule))
            {
                _info.modules.addModule(module = new StatusModule(statusModelType));
                module.addListener(_applyStatus);
                module.addListener(_applyInteraction);
                _initializeStatus();
            }
            else
            {
                module = _info.modules.getModule(StatusModule) as StatusModule;
                module.addListener(_applyStatus);
                module.addListener(_applyInteraction);
                _applyInteraction(module.headGroup, module.headStatus);
            }
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
        
        override public function reset():void
        {
            if (_info.modules && !_info.modules.isUndefined(StatusModule))
            {
                _info.modules.getModule(StatusModule).removeListener(_applyStatus);
                _info.modules.getModule(StatusModule).removeListener(_applyInteraction);
            }
            
            super.reset();
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            if (_info.modules && !_info.modules.isUndefined(StatusModule))
            {
                _info.modules.getModule(StatusModule).removeListener(_applyStatus);
                _info.modules.getModule(StatusModule).removeListener(_applyInteraction);
            }
            
            super.destroy(withReference);
        }
    }
}