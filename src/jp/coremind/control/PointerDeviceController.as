package jp.coremind.control
{
    import jp.coremind.model.IRuntimeModel;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.Storage;
    import jp.coremind.utility.data.Status;

    public class PointerDeviceController
    {
        public function refresh(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.LOCK, null);
        }
        
        public function enable(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.LOCK, Status.UNLOCK);
        }
        
        public function disable(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.LOCK, Status.LOCK);
        }
        
        public function toggleEnable(storageId:String):void
        {
            var model:IRuntimeModel = Storage.requestModel(storageId).getRuntimeModel(StatusModel);
            
            _isButtonEnable(model) ?
                model.update(StatusGroup.LOCK, Status.LOCK):
                model.update(StatusGroup.LOCK, Status.UNLOCK);
        }
        
        protected function _isButtonEnable(model:IRuntimeModel):Boolean
        {
            var _mss:StatusModel = model as StatusModel;
            return _mss ? !_mss.equalGroup(StatusGroup.LOCK) || _mss.equal(Status.UNLOCK): false;
        }
    }
}