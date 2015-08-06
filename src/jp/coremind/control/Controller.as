package jp.coremind.control
{
    import flash.utils.Dictionary;

    public class Controller
    {
        /** Controller未定義用汎用コントローラー */
        public static const UNDEFINED_CONTROL:Controller = new Controller();
        
        private static const _POINTER_DEVICE:PointerDeviceController = new PointerDeviceController();
        private static const _BUTTON:ButtonController = new ButtonController();
        private static const _SWITCH:SwitchController = new SwitchController();
        
        /** 生成済みコントローラーのキャッシュリスト */
        private static const _LIST:Dictionary = new Dictionary(true);
        
        public static function getInstance(controlClass:Class):Controller
        {
            return controlClass in _LIST ? _LIST[controlClass]: _LIST[controlClass] = new controlClass();
        }
        
        public function Controller()
        {
        }
        
        public function action(dispathedStorageModelId:String, ...params):void
        {
            _BUTTON.select(dispathedStorageModelId);
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
    }
}