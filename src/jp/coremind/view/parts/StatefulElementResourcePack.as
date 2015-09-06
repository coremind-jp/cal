package jp.coremind.view.parts
{
    import jp.coremind.view.abstract.IElement;

    public class StatefulElementResourcePack
    {
        private var _resoucePack:Object;
        
        public function StatefulElementResourcePack()
        {
            _resoucePack = {};
        }
        
        public function destroy():void
        {
            for (var key:String in _resoucePack)
            {
                var list:Vector.<IStatefulElementResource> = _getResouceList(key);
                
                for (var i:int = 0, len:int = list.length; i < len; i++) 
                    list[i].destroy();
                list.length = 0;
                
                _resoucePack[key] = null;
                delete _resoucePack[key];
            }
        }
        
        public function addResource(group:String, status:String, resource:IStatefulElementResource):StatefulElementResourcePack
        {
            var key:String = group + status;
            _getResouceList(key).push(resource);
            
            return this;
        }
        
        public function apply(group:String, status:String, parent:IElement):void
        {
            var key:String = group + status;
            var list:Vector.<IStatefulElementResource> = _getResouceList(key);
            var callExec:Boolean = false;
            
            for (var i:int = 0, len:int = list.length; i < len; i++) 
            {
                var resouce:IStatefulElementResource = list[i];
                
                if (resouce.isThreadType())
                {
                    callExec = true;
                    
                    parent.controller.asyncProcess.pushThread(
                        parent.storageId+key,
                        resouce.createThread(parent),
                        resouce.parallelThread,
                        resouce.asyncThread);
                }
                else
                    resouce.apply(parent);
            }
            
            if (callExec) parent.controller.asyncProcess.exec(parent.storageId+key);
        }
        
        private function _getResouceList(key:String):Vector.<IStatefulElementResource>
        {
            return key in _resoucePack ?
                _resoucePack[key]:
                _resoucePack[key] = new <IStatefulElementResource>[];
        }
    }
}