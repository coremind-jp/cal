package jp.coremind.view.interaction
{
    import jp.coremind.view.abstract.IElement;
    
    public class Interaction implements IElementInteraction
    {
        public function Interaction()
        {
        }
        
        public function destroy():void
        {
        }
        
        public function apply(parent:IElement):void
        {
        }
        
        public function get applyTargetName():String
        {
            return null;
        }
    }
}