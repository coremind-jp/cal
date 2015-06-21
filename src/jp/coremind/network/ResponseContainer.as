package jp.coremind.network
{
    import flash.utils.ByteArray;
    
    import jp.coremind.resource.IByteArrayContent;

    public class ResponseContainer
    {
        private var
            _source:*,
            _parser:IByteArrayContent;
        
        public function ResponseContainer(contentParser:IByteArrayContent)
        {
            _parser = contentParser;
            _source = _parser.createFailedContent();
        }
        
        public function destroy():void
        {
            _source  = null;
            _parser = null;
        }
        
        public function removeSource():*
        {
            var _tmp:* = _source;
            destroy();
            return _tmp;
        }
        
        public function clone():*
        {
            return _parser.clone(_source);
        }
        
        public function setContent(f:Function, binary:ByteArray):void
        {
            if (binary && 0 < binary.length)
            {
                binary.position = 0;
                _parser.extract(function(source:*):void
                {
                    _source = source;
                    f();
                }, binary);
            }
            else f();
        }
    }
}