package jp.coremind.configure
{
    import jp.coremind.core.Layer;
    import jp.coremind.utility.Log;

    public class ViewLayerConfigure
    {
        private var
            _nameList:Vector.<String>;
        
        public function ViewLayerConfigure()
        {
            _nameList = new <String>[];
        }
        
        public function get viewLength():int
        {
            return _nameList.length;
        }
        
        public function getLayerName(index:int):String
        {
            if (0 <= index && index < _nameList.length)
                return _nameList[index];
            
            Log.warning("[ViewLayerConfigure] index is out of range. expect:", index, " actual layer length:", _nameList.length);
            return null;
        }
        
        public function initialize():void
        {
            insertCustomLayer(Layer.CONTENT);
            insertCustomLayer(Layer.NAVIGATION);
            insertCustomLayer(Layer.POPUP);
            insertCustomLayer(Layer.SYSTEM);
        }
        
        public function insertCustomLayer(name:String, index:int = -1):void
        {
            if (_nameList.indexOf(name) == -1)
            {
                if (index == -1) _nameList.push(name);
                else
                {
                    0 <= index && index < _nameList.length ?
                        _nameList.splice(index, 0, name):
                        Log.error("[ViewLayerConfigure] index is out of range. expect:", index, " actual layer length:", _nameList.length);
                }
            }
            else Log.warning("[ViewLayerConfigure] already defined layer name.", name);
        }
    }
}