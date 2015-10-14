package jp.coremind.control
{
    import flash.utils.Dictionary;
    
    import jp.coremind.configure.IViewTransition;
    import jp.coremind.configure.LayerType;
    import jp.coremind.core.Application;
    import jp.coremind.core.ViewAccessor;
    import jp.coremind.model.ElementModel;
    import jp.coremind.model.ViewModel;
    import jp.coremind.storage.StorageModelReader;
    import jp.coremind.utility.Log;

    public class Controller extends ViewAccessor
    {
        /** 生成済みコントローラーのキャッシュリスト */
        private static const _CONTROLLER_LIST:Dictionary = new Dictionary(true);
        public  static function getInstance(controlClass:Class = null, viewModel:ViewModel = null):Controller
        {
            if (!controlClass) controlClass = Controller;
            
            return controlClass in _CONTROLLER_LIST ?
                _CONTROLLER_LIST[controlClass]:
                _CONTROLLER_LIST[controlClass] = new controlClass(viewModel);
        }
        
        private var _viewModel:ViewModel;
        
        public function Controller(viewModel:ViewModel = null)
        {
            _viewModel = viewModel;
        }
        
        public function updateView(transition:IViewTransition, terminateAsyncProcess:Boolean = true):void
        {
            if (terminateAsyncProcess)
                asyncProcess.terminateAll();
            
            transition.layerType === LayerType.STARLING ?
                starlingRoot.updateView(transition):
                flashRoot.updateView(transition);
        }
        
        protected function joinId(...elementIdList):String
        {
            return elementIdList.join(".");
        }
        
        protected function createScrollContainerId(elementId):String
        {
            return elementId+"ScrollWrapper."+elementId;
        }
        
        protected function get viewModel():ViewModel
        {
            return _viewModel;
        }
        
        /**
         * ビューからの呼び出しを処理する.
         * @param   storageId       呼び出しもとのElementオブジェクトが保持するStorageModelReaderオブジェクトのStorageId
         * @param   elementId       呼び出しもとのElementオブジェクトが保持するElementModelIdオブジェクト
         * @param   ...params       拡張パラメータ
         */
        public function exec(method:String, ...params):void
        {
            method in this && this[method] is Function ?
                this[method].apply(params):
                Log.warning("undefined Controller method.", this,
                "\n[undefined method]", method,
                "\n[params]", params);
        }
        
        public function notifyClick(elementId:String, ...params):void
        {
            if (elementId.search(/\.[0-9]+$/) == -1)
                onClickElement(elementId, params);
            else
            {
                var split:Array = elementId.split(".");
                var index:int = split.pop();
                onClickListElement(split.join("."), index, params);
            }
        }
        
        protected function onClickElement(elementId:String, params:Array):void
        {
            Log.info("onClick", elementId, params);
        }
        
        protected function onClickListElement(elementId:String, index:int, params:Array):void
        {
            Log.info("onClickListElement", elementId, index, params);
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public function requestModelReader(storageId:String):StorageModelReader
        {
            return _storage.requestModelReader(storageId, Application.configure.storage.getStorageType(storageId));
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public function requestModelElementModel(storageId:String, elementId:String):ElementModel
        {
            return _storage.requestElementModel(storageId, elementId);
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public function deleteElementModel(elementId:String):void
        {
            _storage.deleteElementModel(elementId);
        }
        
        /**
         * 同期プロセスオブジェクトコントローラーを返す.
         * プロセスオブジェクトとはsyncProcessControllerクラス
         */
        public function get syncProcess():SyncProcessController
        {
            return getInstance(SyncProcessController) as SyncProcessController;
        }
        
        /**
         * 非同期プロセスオブジェクトコントローラーを返す.
         * プロセスオブジェクトとはAsyncProcessControllerクラス
         */
        public function get asyncProcess():AsyncProcessController
        {
            return getInstance(AsyncProcessController) as AsyncProcessController;
        }
    }
}