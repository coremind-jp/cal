package jp.coremind.utility
{
    import flash.utils.Dictionary;

    /**
     * IRecyleインターフェースを実装したクラスインスタンスをプールするクラス.
     * 生成と削除の頻度が高いインスタンスの再利用を目的とする。
     */
    public class InstancePool
    {
        public static const TAG:String = "InstancePool";
        //Log.addCustomTag(TAG);
        
        private var
            _pool:Dictionary;
        
        public function InstancePool():void
        {
            _pool = new Dictionary(true);
        }
        
        public function destroy():void
        {
            Log.custom(TAG, "destroy");
            for (var key:Class in _pool)
            {
                release(key);
                delete _pool[key];
            }
        }
        
        /**
         * プールから利用可能なインスタンスを取得する.
         * プールに利用可能なインスタンスがない場合nullを返す。
         */
        public function request(klass:Class, ...params):IRecycle
        {
            var pool:Array = _getPool(klass);
            var hasPool:Boolean = pool.length > 0;
            var instance:IRecycle = hasPool ? pool.shift(): null;
            
            Log.custom(TAG, "request", klass, "recycle ?", hasPool);
            
            return instance;
        }
        
        /**
         * 不要になったインスタンスをプールへ入れる.
         * requestメソッド呼び出し時に再び使用される。
         */
        public function recycle(instance:IRecycle):void
        {
            instance.reset();
            
            var klass:Class = $.getClassByInstance(instance);
            
            Log.custom(TAG, "recycle", klass);
            
            _getPool(klass).push(instance);
        }
        
        /**
         * パラメータklassのクラスインスタンスプールを全て破棄する.
         * このメソッドを呼ぶとプールされているクラスインスタンスは全て再利用不可能とされる。
         */
        public function release(klass:Class):void
        {
            Log.custom(TAG, "release", klass);
            var pool:Array = _getPool(klass);
            while (pool.length > 0) (pool.pop() as IRecycle).destroy();
        }
        
        /**
         * パラメータklassのクラスインスタンスプールを取得する.
         */
        private function _getPool(klass:Class):Array
        {
            return klass in _pool ? _pool[klass]: _pool[klass] = [];
        }
    }
}