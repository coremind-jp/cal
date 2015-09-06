package jp.coremind.view.parts
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.buildin.Image;
    
    import starling.textures.Texture;
    
    public class TextureResouce extends StatefulElementResource implements IStatefulElementResource
    {
        private var _texture:Texture;
        
        public function TextureResouce(applyTargetName:String, texture:Texture)
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
            var child:Image = parent.getPartsByName(_name);
            
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