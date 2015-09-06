package jp.coremind.view.builder
{
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Application;
    import jp.coremind.model.Diff;
    import jp.coremind.model.IStorageListener;
    import jp.coremind.model.StorageModelReader;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.InstancePool;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.layout.LayoutCalculator;
    
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
            _builderCache:Object,
            _reader:StorageModelReader,
            _pool:InstancePool,
            _createdInstance:Dictionary;

        public function ListElementFactory()
        {
            _builderCache    = {};
            _pool            = new InstancePool();
            _createdInstance = new Dictionary(true);
        }
        
        public function destroy():void
        {
            _reader.removeListener(this);
            _reader = null;
            
            _pool.destroy();
            
            for (var p:* in _builderCache) delete _builderCache[p];
            
            for (var q:* in _createdInstance) delete _createdInstance[q];
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
            if (hasElement(modelData))
                return _createdInstance[modelData];
            
            var l:Array = _reader.read();
            if (length == -1) length = l.length;
            
            var n:int = l.indexOf(modelData);
            if (index == -1) index = n == -1 ? length: n;
            
            var builderName:String = getBuilderName(modelData, index, length);
            
            var builder:ElementBuilder = builderName in _builderCache ?
                _builderCache[builderName]:
                _builderCache[builderName] = Application.elementBluePrint.createBuilder(builderName);
            
            var r:IRecycle = _pool.request(builder.elementClass);
            
            var e:IElement = _createdInstance[modelData] = r ?
                r as IElement:
                builder.buildForListElement();
            
            elementInitializer(e, builder, actualParentWidth, actualParentHeight, modelData, index, length);
            
            return e;
        }
        
        /**
         * modelData, index, lengthパラメータを元に生成するIElementインターフェースを実装したクラスを返す.
         */
        public function elementInitializer(element:IElement, builder:ElementBuilder, actualParentWidth:int, actualParentHeight:int, modelData:*, index:int, length:int):void
        {
            var calculator:LayoutCalculator = builder.requestLayoutCalculator();
            
            element.initialize(_reader.id + "." + index);
            element.initializeElementSize(
                calculator.width.calc(actualParentWidth),
                calculator.height.calc(actualParentHeight));
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
            if (hasElement(modelData))
            {
                var e:IElement = _createdInstance[modelData];
                delete _createdInstance[modelData];
                
                _pool.recycle(e as IRecycle);
            }
        }
    }
}