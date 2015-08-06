package jp.coremind.control
{
    import jp.coremind.model.IRuntimeModel;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.Storage;
    import jp.coremind.utility.data.Status;

    public class SwitchController
    {
        public function refresh(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.SELECT, null);
        }
        
        public function on(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.SELECT, Status.ON);
        }
        
        public function off(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.SELECT, Status.OFF);
        }
        
        public function toggleSwitch(storageId:String):void
        {
            var model:IRuntimeModel = Storage.requestModel(storageId).getRuntimeModel(StatusModel);
            
            _isOnStatus(model) ?
                model.update(StatusGroup.SELECT, Status.OFF):
                model.update(StatusGroup.SELECT, Status.ON);
        }
        
        protected function _isOnStatus(model:IRuntimeModel):Boolean
        {
            var _mss:StatusModel = model as StatusModel;
            return _mss ? _mss.getGroupStatus(StatusGroup.SELECT).equal(Status.ON): false;
        }
    }
}