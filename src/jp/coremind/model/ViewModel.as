package jp.coremind.model
{
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.abstract.IView;
    import jp.coremind.model.module.StatusGroup;
    import jp.coremind.model.module.StatusModel;
    
    public class ViewModel
    {
        private var
            _view:IView;
        
        public function ViewModel(view:IView)
        {
            _view = view;
        }
        
    //alias
        public function updateStatefulElement(elementId:String, statusGroup:String, statusValue:String):void
        {
            _view.getElement(elementId).elementModel
                .getModule(StatusModel).update(statusGroup, statusValue);
        }
        
        public function buttonPress(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.PRESS, Status.DOWN);
        }
        
        public function buttonSelect(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.PRESS, Status.CLICK);
        }
        
        public function buttonRelease(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.PRESS, Status.UP);
        }
        
        public function buttonRollOver(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.RELEASE, Status.ROLL_OVER);
        }
        
        public function buttonRollOut(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.RELEASE, Status.ROLL_OUT);
        }
        
        public function buttonEnable(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.LOCK, Status.UNLOCK);
        }
        
        public function buttonDisable(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.LOCK, Status.LOCK);
        }
        
        public function buttonToggle(elementId:String):void
        {
            var module:IElementModel = _view.getElement(elementId).elementModel.getModule(StatusModel);
            
            _isButtonEnable(module) ?
                module.update(StatusGroup.LOCK, Status.LOCK):
                module.update(StatusGroup.LOCK, Status.UNLOCK);
        }
        
        private function _isButtonEnable(module:IElementModel):Boolean
        {
            var _mss:StatusModel = module as StatusModel;
            return _mss ? !_mss.equalGroup(StatusGroup.LOCK) || _mss.equal(Status.UNLOCK): false;
        }
        
        public function switchOn(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.SELECT, Status.ON);
        }
        
        public function switchOff(elementId:String):void
        {
            updateStatefulElement(elementId, StatusGroup.SELECT, Status.OFF);
        }
        
        public function switchToggle(elementId:String):void
        {
            var module:IElementModel = _view.getElement(elementId).elementModel.getModule(StatusModel);
            
            _isOnStatus(module) ?
                module.update(StatusGroup.SELECT, Status.OFF):
                module.update(StatusGroup.SELECT, Status.ON);
        }
        
        private function _isOnStatus(module:IElementModel):Boolean
        {
            var _mss:StatusModel = module as StatusModel;
            return _mss ? _mss.getGroupStatus(StatusGroup.SELECT).equal(Status.ON): false;
        }
    //alias
    }
}