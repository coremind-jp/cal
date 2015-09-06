package jp.coremind.view.parts
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.TextField;
    
    public class TextResource extends StatefulElementResource implements IStatefulElementResource
    {
        protected var _text:*;
        
        public function TextResource(applyTargetName:String, text:*)
        {
            super(applyTargetName);
            
            _text = text;
        }
        
        public function destroy():void
        {
            _text = null;
        }
        
        public function apply(parent:IElement):void
        {
            var tf:TextField = parent.getPartsByName(_name);
            
            if (tf) tf.text = _text is Function ? _text(): _text;
            else Log.warning("undefined Parts(TextField). name=", _name);
        }
        
        public function isThreadType():Boolean
        {
            return false;
        }
        
        public function createThread(parent:IElement):Thread
        {
            return null;
        }
        
        public function get parallelThread():Boolean
        {
            return false;
        }
        
        public function get asyncThread():Boolean
        {
            return false;
        }
    }
}