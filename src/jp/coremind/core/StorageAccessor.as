package jp.coremind.core
{
    import flash.events.EventDispatcher;
    import jp.coremind.storage.Storage;

    public class StorageAccessor extends EventDispatcher
    {
        private static var _STORAGE:Storage;
        
        public  static function initialize(storage:Storage):void
        {
            _STORAGE = storage;
        }
        
        protected function get _storage():Storage
        {
            return _STORAGE;
        }
    }
}