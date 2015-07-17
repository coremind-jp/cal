package jp.coremind.utility
{
    import flash.events.Event;
    
    import jp.coremind.data.HashList;

    public class MultistageStatus
    {
        public static const TAG:String = "[MultistageStatus]";
        Log.addCustomTag(TAG);
        
        public static const PRIORITY_SYSTEM:int        = int.MAX_VALUE;
        public static const STATUS_GROUP_SYSTEM:String = "statusGroupSystem";
        
        private static const EVENT:Event = new Event(Event.CHANGE);
        
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
            _priorityList:HashList,
            _statusList:Object;
        
        public function MultistageStatus(priorityList:Array = null)
        {
            _statusList = {};
            
            if (priorityList)
            {
                _isClonedPriorityList = true;
                _priorityList = new HashList(priorityList);
                
                //todo conflict check
                for (var i:int, len:int = priorityList.length; i < len; i++) 
                    _statusList[priorityList[i].group] = new Status(priorityList[i].initialStatus);
            }
            else
            {
                _isClonedPriorityList = false;
                _priorityList = new HashList([]);
            }
        }
        
        public function destroy():void
        {
            _priorityList.destory();
            
            for (var p:String in _statusList)
                delete _statusList[p];
        }
        
        public function get value():String
        {
            var activeStatus:Status = _getActiveStatus();
            return activeStatus ? activeStatus.value: null;
        }
        
        private function _getActiveStatus():Status
        {
            return _getStatus(this.group);
        }
        
        private function _getStatus(group:String):Status
        {
            return _statusList[group];
        }
        
        public function get group():String
        {
            return _priorityList.length > 0 ? _priorityList.headElement.group: null;
        }
        
        public function getGroupStatus(group:String):Status
        {
            return _statusList[group];
        }
        
        public function createGroup(group:String, priority:int, decrementCondition:Array):MultistageStatus
        {
            if (_isClonedPriorityList)
            {
                Log.warning("[MultistageStatus] can not createGroup. priorityList is external reference.");
                return this;
            }
            
            if (_getStatus(group))
                return this;
            
            _statusList[group] = new Status(Status.IDLING);
            
            _priorityList.source.push({
                group: group,
                priority:priority,
                decrementCondition: decrementCondition
            });
            
            var beforeName:String = this.group;
            _priorityList.source.sortOn("priority", Array.NUMERIC|Array.DESCENDING);
            
            if (beforeName && beforeName != this.group)
                _priorityList.jump(_priorityList.findIndex("group", beforeName));
            
            return this;
        }
        
        public function equal(expect:String):Boolean
        {
            return 0 == _priorityList.length ? false: _getActiveStatus().equal(expect);
        }
        
        public function equalGroup(expect:String):Boolean
        {
            return 0 == _priorityList.length ? false: group === expect;
        }
        
        public function update(group:String, status:String):void
        {
            var  activeStatus:Status = _getStatus(group);
            if (!activeStatus)
            {
                Log.warning("[MultistageStatus] update is canceled. undefined status group", group);
                return;
            }
            
            
            var n:int = _priorityList.findIndex("group", group);
            //現在のグループステータスのプライオリティーより高いプライオリティーのグループステータスのステータス変更があった場合はその更新を受け入れる
            if (n <= _priorityList.head)
            {
                activeStatus.update(status);
                _priorityList.jump(n);
            }
            else
            //例外としてignorePriorityが設定されている場合はプライオリティーに関係なくステータスの更新を受け入れる
            if (_priorityList.getElement(n).ignorePriority)
                activeStatus.update(status);
            
            do {
                var condition:Array   = _priorityList.headElement.decrementCondition;
                var groupDown:Boolean = condition.indexOf(status) != -1;
                if (groupDown)
                {
                    _priorityList.next();
                    status = value;
                }
            } while (groupDown && !_priorityList.isLast());
        }
        
        public function forcedChangeGroup(group:String):void
        {
            var n:int = _priorityList.findIndex("group", group);
            if (n != -1) _priorityList.jump(n);
        }
        
        public function toString():String
        {
            var result:String = Log.toString(
                "currentStatusGroup:", group,
                "\ncurrentStatusValue:", value,
                "\npriorityList", _priorityList,
                "\nstatusList", _statusList);
            
            return result;
        }
    }
}