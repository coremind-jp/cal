package jp.coremind.view.starling.component
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Process;
    import jp.coremind.core.Routine;
    import jp.coremind.core.Thread;
    import jp.coremind.model.Diff;
    import jp.coremind.model.ListDiff;
    import jp.coremind.model.StorageAccessor;
    import jp.coremind.model.TransactionLog;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.InstancePool;
    import jp.coremind.utility.Log;
    import jp.coremind.view.IElement;
    import jp.coremind.view.layout.LayoutSimulation;
    import jp.coremind.view.layout.ILayout;
    import jp.coremind.view.starling.ElementContainer;
    
    /**
     * 
     */
    public class ListContainer extends ElementContainer
    {
        public static const TAG:String = "[ListContainer]";
        Log.addCustomTag(TAG);
        
        private var
            _childClass:Class,
            _layout:ILayout,
            _pool:InstancePool,
            _simulation:LayoutSimulation,
            _bindedElements:Dictionary,
            _childSize:Point;
        
        public function ListContainer(childClass:Class, layout:ILayout)
        {
            _childClass     = childClass;
            _layout         = layout;
            _pool           = new InstancePool();
            _simulation     = new LayoutSimulation();
            _bindedElements = new Dictionary(true);
            
            var child:IElement = new childClass();
            _childSize = new Point(child.elementWidth, child.elementHeight);
        }
        
        override public function initialize(storage:StorageAccessor):void
        {
            super.initialize(storage);
            
            var list:Array = _storage.read();
            for (var i:int = 0, len:int = list.length; i < len; i++) 
            {
                var p:Point = _layout.calcPosition(_childSize.x, _childSize.y, i);
                _simulation.addChild(list[i], new Rectangle(p.x, p.y, _childSize.x, _childSize.y));
            }
            _simulation.refresh(x, y);
            
            var added:Dictionary = _simulation.added;
            for (var key:* in added)
            {
                var rect:Rectangle = added[key];
                var e:IElement = _requestElement(key);
                e.x = rect.x;
                e.y = rect.y;
                addElement(e);
            }
            _updateElementSize(p.x + _childSize.x, p.y + _childSize.y);
        }
        
        override public function destroy():void
        {
            _childClass = null;
            _layout = null;
            
            _simulation.destroy();
            _pool.destroy();
            
            for (var p:* in _bindedElements) delete _bindedElements[p];
            
            super.destroy();
        }
        
        override public function preview(plainDiff:Diff):void
        {
            var diff:ListDiff     = plainDiff as ListDiff;
            var process:Process   = new Process(name + " (ListContainer::preview).");
            var moveThread:Thread = new Thread("move");
            var addThread:Thread  = new Thread("add");
            var len:int = diff.editedOrigin.length;
            var beforePosition:Dictionary;
            var p:Point = _layout.calcPosition(_childSize.x, _childSize.y, len == 0 ? 0: len - 1).clone();
            
            if (len > 2500)//リスト長が2500以上の場合待機時間を設ける
                process.pushThread(new Thread("sort waiting").pushRoutine(
                    $.loop.highResolution.createWaitProcess(len / 20)//リスト長の20分の1を待機時間にする
                ), false, false)
            
            disablePointerDeviceControl();
            
            beforePosition = _updateElementPosition(diff);
            
            _applyRemoveDiff(diff.removed, process);
            
            _applyFilteringDiff(diff.filtered, process);
            
            _refreshElementOrder(diff, beforePosition, moveThread, addThread, process);
            
            _applyAddDiff(diff.added, addThread, len);
            
            process
                .pushThread(addThread,  true, true)
                .pushThread(moveThread, true, true)
                .exec(function (process:Process):void
                {
                    _updateElementSize(p.x + _childSize.x, p.y + _childSize.y);
                    enablePointerDeviceControl();
                });
        }
        
        override public function commit(plainDiff:Diff):void
        {
            var diff:ListDiff = plainDiff as ListDiff;
            var editedOrigin:Array = diff.editedOrigin;
            var i:int, len:int;
            
            for (i = 0, len = diff.removed.length; i < len; i++)
                _simulation.removechild(diff.removed[i].value);
            
            for (i = 0, len = diff.added.length; i < len; i++)
            {
                var p:Point = _layout.calcPosition(_childSize.x, _childSize.y, editedOrigin.length - len + i);
                _simulation.addChild(diff.added[i].value, new Rectangle(p.x, p.y, _childSize.x, _childSize.y));
            }
            
            for (i = 0, len = editedOrigin.length; i < len; i++)
            {
                var e:IElement = _requestElement(editedOrigin[i]);
                e.storage.updateLocalId(i.toString());
                //e.initialize(e.storage);//debug
            }
        }
        
        /**
         * このコンテナのLayoutSimulationインスタンスを取得する.
         */
        public function get layoutSimulation():LayoutSimulation
        {
            return _simulation;
        }
        
        override public function refresh():void
        {
            if (_requireRefresh())
                _refresh();
        }
        
        /**
         * 現在のコンテナの座標で描画領域を更新した際に内包する子が追加、または削除され子の描画状態を更新する必要があるかを示す値を返す.
         */
        private function _requireRefresh():Boolean
        {
            var invokable:Boolean = false;
            var data:*;
            
            //Log.info("_requireRefresh", x, y);
            _simulation.refresh(x, y);
            for (data in _simulation.added)   { return true; }
            for (data in _simulation.removed) { return true; }
            return false;
        }
        
        /**
         * LayoutSimulationインスタンスに従い内包する子の描画状態を更新する.
         */
        private function _refresh():void
        {
            var process:Process   = new Process(name + " (ListContainer::refresh)");
            var addThread:Thread  = new Thread("add");
            var e:IElement;
            var to:Rectangle;
            var data:*;
            
            for (data in _simulation.removed) 
            {
                if (!_hasElement(data)) continue;
                
                e  = _requestElement(data);
                process.pushThread(new Thread("remove"+e)
                    .pushRoutine(e.removeTransition(this, e))
                    .pushRoutine(_trashRoutine(data)),
                    false, true);
            }
            
            for (data in _simulation.added) 
            {
                e  = _requestElement(data);
                to = _simulation.added[data];
                addThread.pushRoutine(e.addTransition(this, e, to.x, to.y));
            }
            
            process.pushThread(addThread, true, true).exec();
        }
        
        /**
         * 可視状態に関係なくデータと紐付く全てのエレメント位置座標を最新の並び順に更新する.
         * 更新前の座標を戻り値として返す。
         */
        private function _updateElementPosition(diff:ListDiff):Dictionary
        {
            var beforePosition:Dictionary = new Dictionary(true);
            var origin:Array = _storage.read();
            var edited:Array = diff.editedOrigin;
            var k:int = 0;
            
            for (var i:int = 0, len:int = origin.length; i < len; i++) 
            {
                var r:Rectangle = _simulation.getChild(origin[i]);
                var n:int = edited.indexOf(origin[i]);
                
                beforePosition[origin[i]] = { x:r.x, y:r.y };
                
                var j:int   = n == -1 ? 100000 + k++: diff.order.indexOf(n);
                var p:Point = _layout.calcPosition(_childSize.x, _childSize.y, j);
                r.x = p.x;
                r.y = p.y;
            }
            _simulation.refresh(x, y);
            
            return beforePosition;
        }
        
        /**
         * 差分(削除分)を画面に適用する.
         */
        private function _applyRemoveDiff(removeElementList:Vector.<TransactionLog>, p:Process):void
        {
            for (var i:int = 0, len:int = removeElementList.length; i < len; i++) 
            {
                if (_hasElement(removeElementList[i].value))
                {
                    var e:IElement = _requestElement(removeElementList[i].value);
                    p.pushThread(new Thread("remove"+e)
                        .pushRoutine(e.removeTransition(this, e))
                        .pushRoutine(_trashRoutine(removeElementList[i].value)),
                        false, true);
                }
            }
        }
        
        /**
         * 差分(フィルタリング対象分)を画面に適用する.
         */
        private function _applyFilteringDiff(filteringList:Array, p:Process):void
        {
            for (var i:int = 0, len:int = filteringList.length; i < len; i++) 
            {
                if (_hasElement(filteringList[i]))
                {
                    var e:IElement = _requestElement(filteringList[i]);
                    p.pushThread(new Thread("remove"+e)
                        .pushRoutine(e.removeTransition(this, e))
                        .pushRoutine(_trashRoutine(filteringList[i])),
                        false, true);
                }
            }
        }
        
        /**
         * 差分(並び替え)を画面に適用する.
         */
        private function _refreshElementOrder(diff:ListDiff, beforePosition:Dictionary, moveThread:Thread, addThread:Thread, p:Process):void
        {
            var editedOrigin:Array = diff.editedOrigin;
            for (var i:int = 0, len:int = editedOrigin.length; i < len; i++) 
            {
                var data:* = editedOrigin[ diff.order[i] ];
                var from:Object = beforePosition[data];
                var to:Rectangle;
                var e:IElement;
                
                if (data in _simulation.added)
                {
                    to = _simulation.added[data];
                    e  = _requestElement(data);
                    //このエレメントはフィルタリング解除されて追加されたか？
                    diff.filteringRestored.indexOf(data) == -1 ?
                        //そうでなければ、並び替え前の位置から移動してきたように見せる
                        addThread.pushRoutine(e.addTransition(this, e, from.x, from.y, to.x, to.y)):
                        //そうであれば、移動なしに表示させる
                        addThread.pushRoutine(e.addTransition(this, e, to.x, to.y));
                }
                else
                if (data in _simulation.moved)
                {
                    to = _simulation.moved[data];
                    e  = _requestElement(data);
                    moveThread.pushRoutine(e.mvoeTransition(e, to.x, to.y));
                }
                else
                if (data in _simulation.removed && _hasElement(data))
                {
                    to = _simulation.removed[data];
                    e  = _requestElement(data);
                    p.pushThread(new Thread("remove"+e)
                        .pushRoutine(e.removeTransition(this, e, to.x, to.y))
                        .pushRoutine(_trashRoutine(data)),
                        false, true);
                }
            }
        }
        
        /**
         * 差分(追加)を画面に適用する.
         */
        private function _applyAddDiff(addElementList:Vector.<TransactionLog>, addThread:Thread, elementLength:int):void
        {
            for (var i:int = 0, len:int = addElementList.length; i < len; i++) 
            {
                if (addElementList[i].value in _simulation.contains)
                {
                    var o:int      = addElementList[i].key;
                    var e:IElement = _requestElement(addElementList[i].value);
                    var p:Point    = _layout.calcPosition(e.elementWidth, e.elementHeight, o);
                    
                    e.x = p.x;
                    e.y = p.y;
                    addThread.pushRoutine(e.addTransition(this, e));
                }
            }
        }
        
        /**
         * データに紐付くエレメントを取得する.
         * 存在しない場合、暗黙的に新たにエレメントインスタンスが生成される。
         */
        private function _requestElement(bindData:*):IElement
        {
            if (_hasElement(bindData))
                return _bindedElements[bindData];
            else
            {
                var e:IElement = _pool.request(_childClass) as IElement;
                var n:int = _storage.read().indexOf(bindData);
                var localId:String = String(n == -1 ? _storage.read().length: n);
                
                e.initialize(_storage.createChild(String(localId)));
                
                return _bindedElements[bindData] = e;
            }
        }
        
        /**
         * データとエレメントの紐付けを破棄し参照を外す.
         */
        private function _trashRoutine(bindData:*):Function
        {
            return function(r:Routine, t:Thread):void
            {
                var e:IElement = _bindedElements[bindData];
                delete _bindedElements[bindData];
                
                _pool.trash(e as IRecycle);
                r.scceeded("trash Instance");
            };
        }
        
        /**
         * データに紐付くエレメントが存在するかを示す値を返す.
         */
        private function _hasElement(bindData:*):Boolean
        {
            return bindData in _bindedElements;
        }
    }
}