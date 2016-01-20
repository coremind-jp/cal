package jp.coremind.view.interaction
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.TextField;
    
    public class TextInteraction extends ElementInteraction
    {
        public function TextInteraction(applyTargetName:String)
        {
            super(applyTargetName);
        }
        
        override public function apply(parent:IElement):void
        {
            var tf:TextField = parent.getDisplayByName(_name) as TextField;
            
            tf ?
                tf.text = doInteraction(parent, tf):
                Log.warning("undefined Parts(TextField). name=", _name);
        }
    }
}