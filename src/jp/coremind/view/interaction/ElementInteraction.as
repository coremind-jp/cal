package jp.coremind.view.interaction
{
    import jp.coremind.view.abstract.IElement;

    public class ElementInteraction implements IElementInteraction
    {
        protected var
            _bindKey:String,
            _name:String,
            _injectionCode:Function;
        
        public function ElementInteraction(applyTargetName:String)
        {
            _name = applyTargetName;
        }
        
        /**
         * @inheritdoc
         */
        public function destroy():void
        {
            _name = _bindKey = null;
            _injectionCode = null;
        }
        
        /**
         * @inheritdoc
         */
        public function get applyTargetName():String
        {
            return _name;
        }
        
        public function bindKey(key:String, injectionCode:Function = null):ElementInteraction
        {
            _bindKey = key;
            _injectionCode = injectionCode;
            return this;
        }
        
        /**
         * @inheritdoc
         */
        public function apply(parent:IElement):void {}
        
        /**
         * 定義したインタラクション処理を実行し最新のデータを返す.
         */
        public function doInteraction(parent:IElement, child:* = null):*
        {
            if (_bindKey)
            {
                var transactionResult:* = parent.elementInfo.reader.readTransactionResult();
                var value:* = transactionResult ? transactionResult[_bindKey]: parent.elementInfo.reader.read()[_bindKey];
                
                return _injectionCode is Function ? _injectionCode(value, child): value;
            }
            else
                return _injectionCode is Function ? _injectionCode(null, child): null;
        }
        
        public function getRuntimeValue(parent:*, params:Array):*
        {
            params = params.slice();
            return parent[params.shift()].apply(null, params);
        }
    }
}