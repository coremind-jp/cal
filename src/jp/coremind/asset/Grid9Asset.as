package jp.coremind.asset
{
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    
    public class Grid9Asset extends Sprite implements IDisplayObject
    {
        public function Grid9Asset()
        {
            super();
        }
        
        public function destroy():void
        {
            removeFromParent(true);
        }
    }
}