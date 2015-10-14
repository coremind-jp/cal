package jp.coremind.view.interaction
{
    import jp.coremind.storage.StorageModelReader;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.TextField;
    
    public class TextInteraction extends ElementInteraction implements IElementInteraction
    {
        protected var
            _text:String,
            _isStaticText:Boolean;
        
        public function TextInteraction(applyTargetName:String, text:String, isStaticText:Boolean = false)
        {
            super(applyTargetName);
            
            _text = text || "";
            _isStaticText = isStaticText;
        }
        
        public function destroy():void
        {
            _text = null;
        }
        
        public function apply(parent:IElement):void
        {
            var tf:TextField = parent.getDisplayByName(_name) as TextField;
            if (tf) tf.text = _getText(parent.reader);
            else Log.warning("undefined Parts(TextField). name=", _name);
        }
        
        protected function _getText(reader:StorageModelReader):String
        {
            return _isStaticText ?
                _text:
                _text.replace(/<\$\w*>/gm, function(...result):String
                {
                    var match:String = result[0];
                    var len:int = match.length;
                    if (len == 3)
                        return reader.read();
                    else
                    {
                        var key:String = match.substr(2, len - 3);
                        return reader.read()[key];
                    }
                });
        }
    }
}