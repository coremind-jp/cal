package jp.coremind.view.implement.flash.component
{
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Process;
    import jp.coremind.core.Routine;
    import jp.coremind.core.Thread;
    import jp.coremind.model.Diff;
    import jp.coremind.model.ListDiff;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.model.TransactionLog;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.layout.ILayout;
    import jp.coremind.view.implement.flash.ElementContainer;
    
    /**
     * 
     */
    public class ListContainer extends ElementContainer
    {
        public static const TAG:String = "[ListContainer]";
        Log.addCustomTag(TAG);
        
        private var
            _filteredElements:Array,
            _bindedElements:Dictionary,
            _childClass:Class,
            _layout:ILayout;
        
        public function ListContainer(childClass:Class, layout:ILayout)
        {
            _filteredElements = [];
            _bindedElements   = new Dictionary(true);
            _childClass       = childClass;
            _layout           = layout;
        }
        
        override public function initialize(storage:StorageAccessor):void
        {
            super.initialize(storage);
            
            var list:Array = _storage.read();
            for (var i:int = 0, len:int = list.length; i < len; i++) 
            {
                var e:IElement = _requestElement(list[i]);
                var p:Point = _layout.calcPosition(e.elementWidth, e.elementHeight, i, len);
                e.x = p.x;
                e.y = p.y;
                addElement(e);
            }
        }
        
        override public function destroy():void
        {
            //InstancePool.release(_childClass);
            
            _layout = null;
            _childClass = null;
            
            for (var p:* in _bindedElements)
                delete _bindedElements[p];
            
            _filteredElements.length = 0;
            
            super.destroy();
        }
        
        override public function preview(plainDiff:Diff):void
        {/*
            var diff:ListDiff     = plainDiff as ListDiff;
            var process:Process   = new Process("ListContainer::preview.");
            var moveThread:Thread = new Thread("move");
            var addThread:Thread  = new Thread("add");
            
            Log.custom(TAG, "----     preview     -----\n\tadd:", diff.added.length, " remove:", diff.removed.length, " filtered:", diff.filtered.length, " order:", diff.order.length);
            
            disablePointerDeviceControl();
            
            _applyRemoveDiff(diff.removed, process);
            
            var filteringRestoreList:Array = _refreshFilteringElements(diff.filtered, process);
            
            _refreshElementOrder(diff, filteringRestoreList, moveThread, addThread);
            
            _applyAddDiff(diff.added, addThread, diff.editedOrigin.length);
            
            process
                .pushThread(moveThread, true, true)
                .pushThread(addThread,  true, false)
                .exec(function (p:Process):void {
                    enablePointerDeviceControl();
                });*/
        }
        
        //削除
        private function _applyRemoveDiff(removeElementList:Vector.<TransactionLog>, p:Process):void
        {
            for (var i:int = 0, len:int = removeElementList.length; i < len; i++) 
            {
                if (!_hasElement(removeElementList[i].value))
                    continue;
                
                var e:IElement = _requestElement(removeElementList[i].value);
                p.pushThread(new Thread("remove"+e)
                    .pushRoutine(e.removeTransition(this, e))
                    .pushRoutine(_trashRoutine(removeElementList[i].value)),
                    false, true);
            }
        }
        
        //フィルタリング対象更新
        private function _refreshFilteringElements(filteringList:Vector.<TransactionLog>, p:Process):Array
        {
            var result:Array = _filteredElements;
            
            _filteredElements = [];
            for (var i:int = 0, len:int = filteringList.length; i < len; i++) 
            {
                Log.custom(TAG, "□", filteringList[i].value, "filtering");
                
                var e:IElement = _requestElement(filteringList[i].value);
                
                _filteredElements.push(e);
                
                var n:int = result.indexOf(e);
                n == -1 ?
                    p.pushThread(new Thread("↑ remove").pushRoutine(e.removeTransition(this, e)), false, true):
                    result.splice(n, i);
            }
            
            return result;
        }
        
        //並び替え, フィルタリング解除
        private function _refreshElementOrder(diff:ListDiff, filteringRestoreList:Array, moveThread:Thread, addThread:Thread):void
        {
            var editedOrigin:Array = diff.editedOrigin;
            
            for (var i:int = 0, len:int = editedOrigin.length; i < len; i++) 
            {
                Log.custom(TAG, i, "order loop value:", editedOrigin[o], "hasElement", _hasElement(editedOrigin[o]));
                
                var o:int      = diff.order[i];
                var e:IElement = _requestElement(editedOrigin[o]);
                var p:Point    = _layout.calcPosition(e.elementWidth, e.elementHeight, i, len);
                var n:int      = filteringRestoreList.indexOf(e);
                
                if (n == -1 && containsElement(e))
                {
                    Log.custom(TAG, " ", o, "->", i, "move");
                    moveThread.pushRoutine(e.mvoeTransition(e, p.x, p.y));
                }
                else
                {
                    Log.custom(TAG, " ■ filtering restore or rollback ->", o);
                    e.x = p.x;
                    e.y = p.y;
                    addThread.pushRoutine(e.addTransition(this, e));
                }
            }
        }
        
        //追加
        private function _applyAddDiff(addElementList:Vector.<TransactionLog>, addThread:Thread, elementLength:int):void
        {
            for (var i:int = 0, len:int = addElementList.length; i < len; i++) 
            {
                Log.custom(TAG, "● ", addElementList[i].value, "pos:"+addElementList[i].key);
                
                var o:int      = addElementList[i].key;
                var e:IElement = _requestElement(addElementList[i].value);
                var p:Point    = _layout.calcPosition(e.elementWidth, e.elementHeight, o, elementLength);
                
                e.x = p.x;
                e.y = p.y;
                addThread.pushRoutine(e.addTransition(this, e));
            }
        }
        
        private function _requestElement(bindData:*):IElement
        {
            if (bindData in _bindedElements)
                return _bindedElements[bindData];
            else
            {
                /*
                var e:IElement = InstancePool.request(_childClass) as IElement;
                var n:int = _storage.read().indexOf(bindData);
                var localId:String = String(n == -1 ? _storage.read().length: n);
                
                Log.custom(TAG, "createInstance value:", bindData, "localId:", localId);
                e.initialize(_storage.createChild(String(localId)));
                
                return _bindedElements[bindData] = e;
                */
                return null;
            }
        }
        
        private function _trashRoutine(bindData:*):Function
        {
            return function(r:Routine, t:Thread):void
            {/*
                var e:IElement = _bindedElements[bindData];
                delete _bindedElements[bindData];
                
                InstancePool.trash(e as IRecycle);*/
                r.scceeded("trash Instance");
            };
        }
        
        private function _hasElement(bindData:*):Boolean
        {
            return Boolean(_bindedElements[bindData])
        }
    }
}