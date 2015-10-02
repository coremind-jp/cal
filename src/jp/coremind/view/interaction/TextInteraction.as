package jp.coremind.view.interaction
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.TextField;
    
    public class TextInteraction extends StatefulElementInteraction implements IStatefulElementInteraction
    {
        protected var _text:*;
        
        public function TextInteraction(applyTargetName:String, text:*)
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
            var tf:TextField = parent.getDisplayByName(_name) as TextField;
            if (tf) tf.text = _getText(parent);
            else Log.warning("undefined Parts(TextField). name=", _name);
        }
        
        protected function _getText(parent:*):String
        {
            return _text is Array ? getRuntimeValue(parent, _text) as String: _text;
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