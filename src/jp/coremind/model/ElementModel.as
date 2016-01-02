package jp.coremind.model
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.Log;

    public class ElementModel
    {
        private var _moduleList:Dictionary;
        
        public function ElementModel()
        {
            _moduleList = new Dictionary(true);
        }
        
        public function destroy():void
        {
            for (var p:* in _moduleList)
                removeModule(p);
            
            _moduleList = null;
        }
        
        public function isUndefined(module:Class):Boolean
        {
            //このオブジェクトの参照は基本的にはStorageModelReaderオブジェクトに格納されていて
            //そのStorageModelReaderオブジェクトの参照はStorageオブジェクトにキャッシュとして存在する。
            
            //Storageオブジェクトはビューの切り替え時にStorageModelReaderオブジェクトをListenしている
            //Elementオブジェクトが存在しない場合に暗黙的にこのオブジェクトを破棄する。
            
            //単一のElementオブジェクトを表示する際には上記の処理に問題はないが
            //ListContainerオブジェクトを利用してElementオブジェクトを表示する場合は破棄処理のコンフリクトが発生しうる。
            
            //理由としてはListContainerオブジェクトはInstancePoolを経由してElementを表示しているため、
            //非表示扱いになったElementが一時的にStorageModelReaderへの参照を解除する場合があり
            //その間にビューの切り替えが発生するとStorageオブジェクトに格納されているキャッシュを消してしまう。
            
            //その結果、非表示扱いになっているElementオブジェクトを格納するInstancePoolが役目を終えて破棄されるときに、
            //既にnullになっている_moduleListを参照しようするので、nullエラーを防ぐために_moduleListがnullかもチェックする必要がある。
            return !_moduleList || !(module in _moduleList);
        }
        
        public function getModule(module:Class):IElementModel
        {
            if (isUndefined(module))
            {
                Log.error("undefined ElementModelModule", module);
                return null;
            }
            else
                return _moduleList[module];
        }
        
        public function addModule(instance:IElementModel):void
        {
            _moduleList[$.getClassByInstance(instance)] = instance;
        }
        
        public function removeModule(module:Class):void
        {
            if (isUndefined(module)) return;
            else getModule(module).destroy();
            
            delete _moduleList[module];
        }
        
        public function toString():String
        {
            return Log.toString(_moduleList);
        }
    }
}