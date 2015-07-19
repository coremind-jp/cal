package jp.coremind.utility
{
    import jp.coremind.configure.StatusConfigure;
    import jp.coremind.configure.UpdateRule;
    import jp.coremind.data.HashList;

    public class MultistageStatus
    {
        public static const TAG:String = "[MultistageStatus]";
        Log.addCustomTag(TAG);
        
        private static const _LOG:Vector.<String> = new <String>[];
        
        /**
         * fromパラメータに指定したpriorityListと第二パラメータ以降に指定したpriorityListをマージした新しい配列を返す.
         */
        public static function margePriorityList(from:Array, ...margeList):Array
        {
            var result:Array = from.concat(margeList);
            
            result.sortOn("priority", Array.NUMERIC|Array.DESCENDING);
            
            return result;
        }
        
        private var
            _isClonedPriorityList:Boolean,
            _sortedConfigList:HashList,
            _statusList:Object;
        
        public function MultistageStatus(configList:Array = null)
        {
            _statusList = {};
            
            if (configList)
            {
                _isClonedPriorityList = true;
                _sortedConfigList = new HashList(configList as Array);
                
                //todo conflict check
                for (var i:int, len:int = configList.length; i < len; i++) 
                    _statusList[configList[i].group] = configList[i].createStatus();
            }
            else
            {
                _isClonedPriorityList = false;
                _sortedConfigList = new HashList([]);
            }
        }
        
        public function destroy():void
        {
            _sortedConfigList.destory();
            
            for (var p:String in _statusList)
                delete _statusList[p];
        }
        
        public function get headStatus():String
        {
            var s:Status = _headStatus;
            return s ? s.value: null;
        }
        
        public function get headGroup():String
        {
            return _sortedConfigList.length > 0 ? _sortedConfigList.headElement.group: null;
        }
        
        public function exportHash():Object
        {
            var result:Object = { __HEAD__:_sortedConfigList.head };
            
            for (var p:String in _statusList)
                result[p] = getGroupStatus(p).value;
            
            return result;
        }
        
        public function importHash(exportHash:Object):void
        {
            for (var p:String in _statusList)
                getGroupStatus(p).update(exportHash[p]);
            
            forcedChangeGroup(exportHash.__HEAD__);
        }
        
        private function get _headConfig():StatusConfigure
        {
            return _sortedConfigList.length > 0 ? _sortedConfigList.headElement: null;
        }
        
        private function get _headStatus():Status
        {
            return getGroupStatus(headGroup);
        }
        
        public function getGroupStatus(group:String):Status
        {
            return _statusList[group];
        }
        
        public function createGroup(group:String, priority:int, decrementCondition:Array):MultistageStatus
        {
            if (getGroupStatus(group))
                return this;
            
            _statusList[group] = new Status(Status.IDLING);
            
            _sortedConfigList.source.push({
                group: group,
                priority:priority,
                decrementCondition: decrementCondition
            });
            
            var beforeName:String = headGroup;
            _sortedConfigList.source.sortOn("priority", Array.NUMERIC|Array.DESCENDING);
            
            if (beforeName && beforeName != headGroup)
                _sortedConfigList.jump(_sortedConfigList.findIndex("group", beforeName));
            
            return this;
        }
        
        public function equal(expect:String):Boolean
        {
            return 0 == _sortedConfigList.length ? false: _headStatus.equal(expect);
        }
        
        public function equalGroup(expect:String):Boolean
        {
            return 0 == _sortedConfigList.length ? false: headGroup === expect;
        }
        
        public function update(group:String, status:String):Vector.<String>
        {
            _LOG.length = 0;
            
            var target:Status = getGroupStatus(group);
            if (!target)
            {
                Log.warning("[MultistageStatus] update is canceled. undefined status group", group);
                return _LOG;
            }
            
            var conf:StatusConfigure;
            var n:int = _sortedConfigList.findIndex("group", group);
            //現在のグループステータスのプライオリティーと同値またはより高いプライオリティーのグループステータスのステータス変更があった場合はその更新を受け入れる
            if (n <= _sortedConfigList.head)
            {
                target.update(status);
                
                _sortedConfigList.jump(n);
                
                _LOG[_LOG.length] = group;
                
                conf = _headConfig;
                
                do {
                    var doStageDown:Boolean = conf.invokableStageDown(status);
                    
                    if (doStageDown)
                    {
                        _sortedConfigList.next();
                        status = headStatus;
                        conf   = _headConfig;
                        
                        if (conf.includeDownStageLog)
                            _LOG[_LOG.length] = conf.group;
                    }
                } while (doStageDown && !_sortedConfigList.isLast());
            }
            else
            {
                //例外としてUpdateRule.ALWAYSが設定されている場合はプライオリティーに関係なくステータスの更新を受け入れる
                conf = _sortedConfigList.getElement(n);
                if (conf.updateRule === UpdateRule.ALWAYS)
                    target.update(status);
            }
            
            return _LOG;
        }
        
        public function forcedChangeGroup(group:String):void
        {
            var n:int = _sortedConfigList.findIndex("group", group);
            if (n != -1) _sortedConfigList.jump(n);
        }
        
        public function toString():String
        {
            var result:String = Log.toString(
                "currentStatusGroup:", headGroup,
                "\ncurrentStatusValue:", headStatus,
                "\npriorityList", _sortedConfigList,
                "\nstatusList", _statusList);
            
            return result;
        }
    }
}