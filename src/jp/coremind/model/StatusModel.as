package jp.coremind.model
{
    import flash.utils.getQualifiedClassName;
    
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.HashList;
    import jp.coremind.utility.data.Status;

    public class StatusModel extends ElementModel implements IElementModel
    {
        public static const TAG:String = "[StatusModel]";
        Log.addCustomTag(TAG);
        
        public static function create(klass:Class):StatusModel
        {
            var configure:Array = StatusModelConfigure.request(klass);
            if (configure)
            {
                return new StatusModel(configure);
            }
            else
            {
                Log.error("undefined StatusModelConfigure from", klass);
                return new StatusModel([]);
            }
        }
        
        private var
            _isUpdating:Boolean,
            _isClonedList:Boolean,
            _sortedConfigList:HashList,
            _statusList:Object;
        
        public function StatusModel(configList:Array = null)
        {
            _statusList = {};
            
            if (configList)
            {
                _isClonedList = true;
                _sortedConfigList = new HashList(configList as Array);
                
                //todo conflict check
                for (var i:int, len:int = configList.length; i < len; i++) 
                    _statusList[configList[i].group] = new Status(configList[i].initialStatus);
            }
            else
            {
                _isClonedList = false;
                _sortedConfigList = new HashList([]);
            }
        }
        
        override public function destroy():void
        {
            Log.info("StatusModel destroy");
            
            _sortedConfigList.destory();
            
            for (var p:String in _statusList) delete _statusList[p];
            
            super.destroy();
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
        
        public function get name():String
        {
            return getQualifiedClassName(this).split("::")[1];
        }
        
        public function reset():void
        {
            for (var p:String in _statusList)
            {
                var n:int = _sortedConfigList.findIndex("group", p);
                _statusList[p].update(_sortedConfigList.getElement(n).initialStatus);
            }
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
        
        public function createGroup(group:String, priority:int, decrementCondition:Array):StatusModel
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
        
        /**
         * 現在のStatusModel.group, valueをパラメータstatusGroupをstatusValueへ更新する.
         * この際に直前まで保持していたgroupとvalueいずれか一つでも異なっている場合、_applyStatusメソッドを呼び出す。
         * 例外としてGROUP_CTRLグループのStatus.MOVEステータスのみ常に_applyStatusを呼び出す。
         * ステータスの更新によって暗黙的にステータスグループに変更があった際に、そのハンドリングを正しく呼び出すためのメソッド。
         */
        private static const _LOG:Vector.<String> = new <String>[];
        public function update(...params):void
        {
            _LOG.length = 0;
            
            var isInitialize:Boolean = params[1] === null;
            var statusGroup:String   = params[0];
            var statusValue:String   = isInitialize ? getGroupStatus(statusGroup).value: params[1];
            
            var updateLog:Vector.<String>;
            var beforeGroup:String   =  headGroup;
            var beforeStatus:String  =  headStatus;
            //Log.info("us", statusGroup, statusValue, isInitialize, "call dispatch?", isInitialize || !equalGroup(beforeGroup) || !equal(beforeStatus));
            
            _updateStageStatus(statusGroup, statusValue);
            
            if (isInitialize || !equalGroup(beforeGroup) || !equal(beforeStatus))
            {
                _isUpdating = true;
                
                updateLog = _LOG.length == 1 ? _LOG: _LOG.slice();
                
                for (var i:int = 0, len:int = updateLog.length; _isUpdating && i < len; i++)
                {
                    //Log.info("dispatch", updateLog[i]);
                    dispatch(updateLog[i], getGroupStatus(updateLog[i]).value);
                }
                
                _isUpdating = false;
            }
        }
        
        protected function _updateStageStatus(group:String, status:String):void
        {
            var target:Status = getGroupStatus(group);
            if (!target)
            {
                Log.warning("[StatusModel] update is canceled. undefined status group", group);
                return;
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