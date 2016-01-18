package jp.coremind.view.interaction
{
    import jp.coremind.storage.ModelReader;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.TextField;
    
    public class TextInteraction extends ElementInteraction implements IElementInteraction
    {
        public static function REPLACE_TO_READER(sourceText:String, reader:ModelReader):String
        {
            return sourceText.replace(/<\$\w*>/gm, function(...result):String
            {
                var match:String = result[0];
                var len:int = match.length;
                
                //<$> (readerが示すデータそのもの)
                if (len == 3)
                    return reader.read();
                //readerが示すハッシュや配列内の要素から取得
                else
                {
                    var key:String = match.substr(2, len - 3);
                    return reader.read()[key];
                }
            });
        };
        
        protected var
            _text:String,
            _replacer:Function;
        
        public function TextInteraction(applyTargetName:String, text:String, replacer:Function = null)
        {
            super(applyTargetName);
            
            _text = text || "";
            _replacer = replacer;
        }
        
        public function destroy():void
        {
            _text = null;
            _replacer = null;
        }
        
        public function apply(parent:IElement):void
        {
            var tf:TextField = parent.getDisplayByName(_name) as TextField;
            if (tf) tf.text = _getText(parent.elementInfo.reader);
            else Log.warning("undefined Parts(TextField). name=", _name);
        }
        
        protected function _getText(reader:ModelReader):String
        {
            return _replacer is Function ? _replacer(_text, reader): _text;
        }
    }
}