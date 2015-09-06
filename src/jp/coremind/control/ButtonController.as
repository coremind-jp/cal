package jp.coremind.control
{
    import jp.coremind.model.ElementModelId;
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.utility.data.Status;

    public class ButtonController extends StorageAccessor
    {
        public function refresh(storageId:String, elementId:ElementModelId):void
        {
            //PRESS更新＝ボタンの押下実行と同等なので更新はしない
            //_storage.requestRuntimeModelAccessor(MultistageStatus, storageId)
            //    .update(TouchElement.PRESS, null);
            
            //再読み込み時は復元状態に関係なくStatus.ROLL_OUTから始める
            rollOut(storageId, elementId);
        }
        
        public function press(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.PRESS, Status.DOWN);
        }
        
        internal function select(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.PRESS, Status.CLICK);
        }
        
        public function release(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.PRESS, Status.UP);
        }
        
        public function rollOver(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.RELEASE, Status.ROLL_OVER);
        }
        
        public function rollOut(storageId:String, elementId:ElementModelId):void
        {
            _storage.requestModel(storageId)
                .getElementModel(elementId, StatusModel)
                .update(StatusGroup.RELEASE, Status.ROLL_OUT);
        }
    }
}