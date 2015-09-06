package jp.coremind.control
{
    import flash.display.Stage;
    import flash.utils.Dictionary;
    
    import jp.coremind.model.ElementModelId;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.model.StorageConfigure;
    import jp.coremind.model.StorageModelReader;

    public class Controller extends StorageAccessor
    {
        /** Controller未定義用汎用コントローラー */
        public  static const UNDEFINED_CONTROL:Controller = new Controller();
        
        private static const _POINTER_DEVICE:PointerDeviceController = new PointerDeviceController();
        private static const _BUTTON:ButtonController = new ButtonController();
        private static const _SWITCH:SwitchController = new SwitchController();
        
        private static var _CPU_VIEW:CpuViewController;
        private static var _GPU_VIEW:GpuViewController;
        public static function initialize(
            stage:Stage,
            initialGpuView:Class,
            initialCpuView:Class):void
        {
            _GPU_VIEW = new GpuViewController();
            _CPU_VIEW = new CpuViewController();
            
            _GPU_VIEW.createRootLayer(stage, initialGpuView);
            _CPU_VIEW.createRootLayer(stage, initialCpuView);
        }
        
        /** 生成済みコントローラーのキャッシュリスト */
        private static const _LIST:Dictionary = new Dictionary(true);
        public  static function getInstance(controlClass:Class):Controller
        {
            return controlClass ?
                controlClass in _LIST ? _LIST[controlClass]: _LIST[controlClass] = new controlClass():
                UNDEFINED_CONTROL;
        }
        
        private var
            _configureByElementName:Object,
            _configureByStorageId:Object,
            _interactionAssociation:Object;
        
        public function Controller()
        {
            _configureByElementName = {};
            _configureByStorageId   = {};
        }
        
        /**
         * StorageConfigureオブジェクトを追加する.
         */
        protected function _addStorageConfigure(configure:StorageConfigure):Controller
        {
            _configureByElementName[configure.elementName] = configure;
            _configureByStorageId[configure.storageId] = configure;
            return this;
        }
        
        /**
         * ビューからの呼び出しを処理する.
         * @param   storageId       呼び出しもとのElementオブジェクトが保持するStorageModelReaderオブジェクトのStorageId
         * @param   elementId       呼び出しもとのElementオブジェクトが保持するElementModelIdオブジェクト
         * @param   ...params       拡張パラメータ
         */
        public function action(storageId:String, elementId:ElementModelId, ...params):void
        {
            _BUTTON.select(storageId, elementId);
        }
        
        /**
         * elementNameパラメータに紐付けているStorageModelReaderオブジェクトを初期化する.
         * @param   elementName エレメント名. _addStorageConfigureで紐付けられている必要がある。
         */
        public function initializeStorageModel(elementName:String):String
        {
            var storageModel:StorageModelReader = _getModelReader(_getStorageConfigureByElementName(elementName));
            return storageModel ? storageModel.id: null;
        }
        
        /**
         * storageIdパラメータに紐づくStorageModelReaderオブジェクトを要求する.
         * @param   storageId   ストレージID. initializeStorageModelで初期化が済んでいるStorageModelReaderのStorageIdまたはその子となるStorageIdでなければならない。
         */
        public function requestModelReader(storageId:String):StorageModelReader
        {
            if (storageId)
            {
                var configure:StorageConfigure = _getStorageConfigureById(storageId);
                return configure ? _getModelReader(configure): _getModelReaderForChildren(storageId);
            }
            else
                return null;
        }
        
        internal function refreshStorage():void
        {
            _storage.refresh();
        }
        
        /**
         * _addStorageConfigureメソッドで追加されたStorageConfigureを元にelementNameに紐付くオブジェクトを取得する.
         */
        private function _getStorageConfigureByElementName(elementName:String):StorageConfigure
        {
            return elementName in _configureByElementName ? _configureByElementName[elementName]: null;
        }
        
        /**
         * _addStorageConfigureメソッドで追加されたStorageConfigureを元にstorageIdに紐付くオブジェクトを取得する.
         */
        private function _getStorageConfigureById(storageId:String):StorageConfigure
        {
            return storageId in _configureByStorageId ? _configureByStorageId[storageId]: null;
        }
        
        /**
         * パラメータcを元にStorageModelReaderを取得する.
         */
        private function _getModelReader(c:StorageConfigure):StorageModelReader
        {
            return c ?
                _storage.isDefined(c.storageId, c.storageType) ?
                    _storage.requestModelReader(c.storageId, c.storageType):
                    _storage.requestModelReader(c.storageId, c.storageType, c.getInitialValue()):
                null;
        }
        
        /**
         * パラメータstorageIdを元にStorageModelReaderを取得する.
         * このメソッドは_getModelReaderでStorageModelReaderが取得できなかった場合に呼び出される。
         * 「取得できない場合」とは、View直下に存在するElementオブジェクトではなく、
         * そのElementオブジェクトが暗黙的に子として生成されたElementオブジェクトからrequestModelReaderメソッドが呼ばれた場合となる。
         * StorageConfigureが生成されるのはView直下のElementのみであり、
         * その下に存在するElemenetやそのオブジェクトに割り当てられるStorageModelReaderはStorageConfigureが生成されたidから参照する必要がある。
         */
        private function _getModelReaderForChildren(storageId:String):StorageModelReader
        {
            if (!storageId) return null;
            
            var i:int = storageId.indexOf(".");
            if (i < 0) return null;
            
            var rootStorageConfigure:StorageConfigure = _getStorageConfigureById(storageId.substring(0, i));
            if (!rootStorageConfigure) return null;
            
            var type:String = rootStorageConfigure.storageType;
            if (!_storage.isDefined(storageId, type)) return null;
            
            return _storage.requestModelReader(storageId, type);
        }
        
        /**
         * インタラクティブオブジェクトコントローラーを返す.
         * インタラクティブオブジェクトとはInteractiveElement、またはそれを継承したクラス
         */
        public function get pointerDevice():PointerDeviceController
        {
            return _POINTER_DEVICE;
        }
        
        /**
         * ボタンオブジェクトコントローラーを返す.
         * ボタンオブジェクトとはTouchElement, MouseElement、またはどちらかを継承したクラス
         */
        protected function get gpuView():GpuViewController
        {
            return _GPU_VIEW;
        }
        
        /**
         * スイッチオブジェクトコントローラーを返す.
         * スイッチオブジェクトとはTouchSwitch, MouseSwitch、またはどちらかを継承したクラス
         */
        protected function get cpuView():CpuViewController
        {
            return _CPU_VIEW;
        }
        
        /**
         * ボタンオブジェクトコントローラーを返す.
         * ボタンオブジェクトとはTouchElement, MouseElement、またはどちらかを継承したクラス
         */
        public function get button():ButtonController
        {
            return _BUTTON;
        }
        
        /**
         * スイッチオブジェクトコントローラーを返す.
         * スイッチオブジェクトとはTouchSwitch, MouseSwitch、またはどちらかを継承したクラス
         */
        public function get buttonSwitch():SwitchController
        {
            return _SWITCH;
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