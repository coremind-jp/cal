package jp.coremind.control
{
    import jp.coremind.model.IElementModel;
    import jp.coremind.model.ElementModelId;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.utility.data.Status;

    public class SwitchController extends StorageAccessor
    {
        public function refresh(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.SELECT, null);
        }
        
        public function on(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.SELECT, Status.ON);
        }
        
        public function off(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.SELECT, Status.OFF);
        }
        
        public function toggleSwitch(storageId:String, elementId:ElementModelId):void
        {
            var model:IElementModel = _storage.requestModel(storageId).getElementModel(elementId, StatusModel);
            
            _isOnStatus(model) ?
                model.update(StatusGroup.SELECT, Status.OFF):
                model.update(StatusGroup.SELECT, Status.ON);
        }
        
        protected function _isOnStatus(model:IElementModel):Boolean
        {
            var _mss:StatusModel = model as StatusModel;
            return _mss ? _mss.getGroupStatus(StatusGroup.SELECT).equal(Status.ON): false;
        }
    }
}