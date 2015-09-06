package jp.coremind.control
{
    import jp.coremind.model.IElementModel;
    import jp.coremind.model.ElementModelId;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.utility.data.Status;

    public class PointerDeviceController extends StorageAccessor
    {
        public function refresh(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.LOCK, null)
        }
        
        public function enable(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.LOCK, Status.UNLOCK);
        }
        
        public function disable(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.LOCK, Status.LOCK);
        }
        
        public function toggleEnable(storageId:String, elementId:ElementModelId):void
        {
            var model:IElementModel = _storage.requestModel(storageId).getElementModel(elementId, StatusModel);
            
            _isButtonEnable(model) ?
                model.update(StatusGroup.LOCK, Status.LOCK):
                model.update(StatusGroup.LOCK, Status.UNLOCK);
        }
        
        protected function _isButtonEnable(model:IElementModel):Boolean
        {
            var _mss:StatusModel = model as StatusModel;
            return _mss ? !_mss.equalGroup(StatusGroup.LOCK) || _mss.equal(Status.UNLOCK): false;
        }
    }
}