package jp.coremind.view.builder
{
    import flash.utils.Dictionary;
    
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.core.Application;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.storage.IStorageListener;
    import jp.coremind.storage.StorageModelReader;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.InstancePool;
    import jp.coremind.view.abstract.IElement;
    
    /**
     * ListConatinerクラスインスタンスの子インスタンスを生成を制御するクラス.
     * requestメソッドでインスタンスを生成する。
     * このクラスから生成されたインスタンスは内部でInstancePoolクラスで管理されているため,
     * 明示的に不要になった事を通知(recycleメソッドの呼び出し)する必要がある。
     * @see InstancePool
     */
    public class ListElementFactory implements IStorageListener
    {
        protected var
            _reader:StorageModelReader,
            _pool:InstancePool,
            _createdInstance:Dictionary,
            _builderCache:Object;/** こまめにElementが追加削除を繰り返す場合Builder取得(呼び出し時に生成している)コストが高くなるので一度使ったbuilderはキャッシュしておく */

        public function ListElementFactory()
        {
            _pool            = new InstancePool();
            _createdInstance = new Dictionary(true);
            _builderCache    = {};
        }
        
        public function destroy():void
        {
            _reader.removeListener(this);
            _reader = null;
            
            _pool.destroy();
            
            for (var q:* in _createdInstance) delete _createdInstance[q];
            
            for (var p:* in _builderCache) delete _builderCache[p];
        }
        
        public function initialize(reader:StorageModelReader):void
        {
            _reader = reader;
            _reader.addListener(this, StorageModelReader.LISTENER_PRIORITY_LIST_ELEMENT_FACTORY);
        }
        
        /**
         * データに紐付くエレメントが存在するかを示す値を返す.
         */
        public function hasElement(bindData:*):Boolean
        {
            return bindData in _createdInstance;
        }
        
        public function preview(plainDiff:Diff):void {}
        public function commit(plainDiff:Diff):void  {}
        
        /**
         * データに紐付くエレメントを取得する.
         * 存在しない場合、暗黙的に新たにエレメントインスタンスが生成される。
         */
        public function request(actualParentWidth:int, actualParentHeight:int, modelData:*, index:int = -1, length:int = -1):IElement
        {
            if (!(modelData in _createdInstance))
            {
                var l:Array = _reader.read();
                if (length == -1) length = l.length;
                
                if (index == -1)
                {
                    var n:int = l.indexOf(modelData);
                    index = n == -1 ? length: n;
                }
                
                var builder:ElementBuilder = _getBuilder(modelData, index, length);
                
                var  element:IElement = _pool.request(builder.getElementClass()) as IElement;
                if (!element) element = builder.buildForListElement();
                element.initialize(actualParentWidth, actualParentHeight, _reader.id + "." + index);
                
                _createdInstance[modelData] = element;
            }
            
            _createdInstance[modelData].name = index.toString();
            
            return _createdInstance[modelData];
        }
        
        protected function _getBuilder(modelData:*, index:int, length:int):ElementBuilder
        {
            var builderName:String = getBuilderName(modelData, index, length);
            
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            
            return builderName in _builderCache ?
                _builderCache[builderName]:
                _builderCache[builderName] = bluePrint.createBuilder(builderName);
        }
        
        public function getBuilderName(modelData:*, index:int, length:int):String
        {
            return "";
        }
        
        /**
         * データとエレメントの紐付けを破棄し参照を外す.
         */
        public function recycle(modelData:*):void
        {
            if (modelData in _createdInstance)
            {
                var e:IElement = _createdInstance[modelData];
                delete _createdInstance[modelData];
                
                _pool.recycle(e as IRecycle);
            }
        }
    }
}