package jp.coremind.model
{
    public class StorageAccessor
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