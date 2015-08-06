package jp.coremind.control
{
    import jp.coremind.model.StatusGroup;
    import jp.coremind.model.StatusModel;
    import jp.coremind.model.Storage;
    import jp.coremind.utility.data.Status;

    public class ButtonController
    {
        public function refresh(storageId:String):void
        {
            //PRESS更新＝ボタンの押下実行と同等なので更新はしない
            //Storage.requestRuntimeModelAccessor(MultistageStatus, storageId)
            //    .update(TouchElement.PRESS, null);
            
            //再読み込み時は復元状態に関係なくStatus.ROLL_OUTから始める
            rollOut(storageId);
        }
        
        public function press(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.PRESS, Status.DOWN);
        }
        
        internal function select(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.PRESS, Status.CLICK);
        }
        
        public function release(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.PRESS, Status.UP);
        }
        
        public function rollOver(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.RELEASE, Status.ROLL_OVER);
        }
        
        public function rollOut(storageId:String):void
        {
            Storage.requestModel(storageId)
                .getRuntimeModel(StatusModel)
                .update(StatusGroup.RELEASE, Status.ROLL_OUT);
        }
    }
}