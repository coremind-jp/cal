package jp.coremind.view.interaction
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    import starling.textures.Texture;
    
    public class TextureInteraction extends StatefulElementInteraction implements IStatefulElementInteraction
    {
        private var _texture:Texture;
        
        public function TextureInteraction(applyTargetName:String, texture:Texture)
        {
            super(applyTargetName);
            
            _texture = texture;
        }
        
        public function destroy():void
        {
            _texture.dispose();
            _texture = null;
        }
        
        public function apply(parent:IElement):void
        {
            var child:Image = parent.getDisplayByName(_name) as Image;
            
            if (child) child.texture = _texture;
            else Log.warning("undefined Parts(Image). name=", _name);
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