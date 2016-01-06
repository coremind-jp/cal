package jp.coremind.view.implement.starling.component
{
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.model.module.ScrollModule;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.model.transaction.ListDiff;
    import jp.coremind.model.transaction.TransactionLog;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.Container;
    import jp.coremind.view.layout.IListLayout;
    import jp.coremind.view.layout.Layout;
    import jp.coremind.view.layout.LayoutSimulation;
    
    public class ListContainer extends Container
    {
        public static const TAG:String = "[ListContainer]";
        Log.addCustomTag(TAG);
        
        private static const PREVIEW_PROCESS:String = "ListContainer::Preview";
        private static const REFRESH_PROCESS:String = "ListContainer::Refresh";
        
        private var
            _listLayout:IListLayout,
            _simulation:LayoutSimulation;
        
        /**
         * 配列データをリスト表示オブジェクトとして表示するコンテナクラス.
         */
        public function ListContainer(
            layout:IListLayout,
            layoutCalculator:Layout,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            
            _listLayout = layout;
            _simulation = new LayoutSimulation();
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            _simulation.destroy();
            
            if (withReference)
                _listLayout.destroy(withReference);
            _listLayout = null;
            
            super.destroy(withReference);
        }
        
        override protected function _initializeElementSize(actualParentWidth:Number, actualParentHeight:Number):void
        {
            Log.custom(TAG, "initializeElementSize", actualParentWidth, actualParentHeight);
            
            _maxWidth  = _layout.width.calc(actualParentWidth);
            _maxHeight = _layout.height.calc(actualParentHeight);
            
            x = _layout.horizontalAlign.calc(actualParentWidth, _maxWidth);
            y = _layout.verticalAlign.calc(actualParentHeight, _maxHeight);
            
            _simulation.setDrawableArea(_maxWidth, _maxHeight);
            
            _refreshLayout(_maxWidth, _maxHeight);
        }
        
        override public function updateElementSize(elementWidth:Number, elementHeight:Number):void
        {
            if (_elementWidth != elementWidth || _elementHeight != elementHeight)
            {
                _elementWidth  = elementWidth;
                _elementHeight = elementHeight;
                
                _refreshLayout(_elementWidth, _elementHeight);
                
                (_elementModel.getModule(ScrollModule) as ScrollModule).refreshContentSize();
                
                dispatchEventWith(ElementEvent.UPDATE_SIZE);
            }
        }
        
        override protected function _onLoadElementInfo():void
        {
            super._onLoadElementInfo();
            
            _listLayout.initialize(_reader);
            
            var list:Array = _reader.read();
            for (var i:int = 0, len:int = list.length; i < len; i++) 
                _simulation.addChild(list[i], _listLayout.calcElementRect(_maxWidth, _maxHeight, i).clone());
            
            var r:Rectangle = _listLayout.calcTotalRect(_maxWidth, _maxHeight, len);
            updateElementSize(r.width, r.height);
            updatePosition(x, y);
        }
        
        override protected function _initializeElementModel():void
        {
            super._initializeElementModel();
            
            if (_elementModel.isUndefined(ScrollModule))
                _elementModel.addModule(new ScrollModule(this));
            
            (_elementModel.getModule(ScrollModule) as ScrollModule).setScrollVolume(
                _listLayout.getScrollSizeX(_maxWidth),
                _listLayout.getScrollSizeY(_maxHeight));
        }
        
        override public function updatePosition(x:Number, y:Number):void
        {
            super.updatePosition(x, y);
            if (_requireRefresh()) _refreshList();
        }
        
        private function _refreshList():void
        {
            var e:IElement;
            var to:Rectangle;
            var data:*;
            
            for (data in _simulation.removed) 
            {
                if (_listLayout.hasCache(data))
                {
                    removeDisplay(_listLayout.requestElement(0, 0, data));
                    _listLayout.requestRecycle(data);
                }
            }
            
            for (data in _simulation.added) 
            {
                to = _simulation.added[data];
                e  = _listLayout.requestElement(to.width, to.height, data);
                e.x = to.x;
                e.y = to.y;
                addDisplay(e);
            }
        }
        
        /**
         * 現在のコンテナの座標で描画領域を更新した際に内包する子が追加、または削除され子の描画状態を更新する必要があるかを示す値を返す.
         */
        private function _requireRefresh():Boolean
        {
            _refreshSimulationPosition(x, y);
            
            var data:*;
            for (data in _simulation.added)   { return true; }
            for (data in _simulation.removed) { return true; }
            return false;
        }
        
        override public function preview(plainDiff:Diff):void
        {
            super.preview(plainDiff);
            
            var pId:String = name + PREVIEW_PROCESS;
            var diff:ListDiff     = plainDiff as ListDiff;
            var moveThread:Thread = new Thread("move");
            var addThread:Thread  = new Thread("add");
            var len:int = diff.editedOrigin.length;
            var beforePosition:Dictionary;
            var r:Rectangle = _listLayout.calcTotalRect(_maxWidth, _maxHeight, len == 0 ? 0: len).clone();
            
            beforePosition = _updateChildrenPosition(diff);
            
            _applyRemoveDiff(diff.removed, pId, len);
            
            _applyFilteringDiff(diff.filtered, pId, len);
            
            _refreshElementOrder(diff, beforePosition, moveThread, addThread, pId);
            
            _applyAddDiff(diff.added, addThread, len);
            
            Application.sync
                .pushThread(pId, addThread,  true, true)
                .pushThread(pId, moveThread, true, true)
                .exec(pId, function (p:Process):void {
                    if (p.result === Status.SCCEEDED) updateElementSize(r.width, r.height);
                });
        }
        
        override public function commit(plainDiff:Diff):void
        {
            super.commit(plainDiff);
            
            var diff:ListDiff = plainDiff as ListDiff;
            var editedOrigin:Array = diff.editedOrigin;
            var i:int, len:int;
            
            for (i = 0, len = diff.removed.length; i < len; i++)
                _simulation.removechild(diff.removed[i].value);
            
            for (i = 0, len = diff.added.length; i < len; i++)
                _simulation.addChild(diff.added[i].value, _listLayout.calcElementRect(_maxWidth, _maxHeight, editedOrigin.length - len + i).clone());
        }
        
        /**
         * 可視状態に関係なくデータと紐付く全てのエレメント位置座標を最新の並び順に更新する.
         * 更新前の座標を戻り値として返す。
         */
        private function _updateChildrenPosition(diff:ListDiff):Dictionary
        {
            var beforePosition:Dictionary = new Dictionary(true);
            var origin:Array = _reader.read();
            var edited:Array = diff.editedOrigin;
            var k:int = 0;
            
            for (var i:int = 0, len:int = origin.length; i < len; i++) 
            {
                var r:Rectangle = _simulation.getChild(origin[i]);
                var n:int = edited.indexOf(origin[i]);
                
                beforePosition[origin[i]] = { x:r.x, y:r.y };
                
                var j:int = n == -1 ? n: diff.order.indexOf(n);
                var s:Rectangle = _listLayout.calcElementRect(_maxWidth, _maxHeight, j);
                r.x = s.x;
                r.y = s.y;
            }
            _refreshSimulationPosition(x, y);
            
            return beforePosition;
        }
        
        /**
         * 差分(削除分)を画面に適用する.
         */
        private function _applyRemoveDiff(removeDisplayList:Vector.<TransactionLog>, pId:String, length:int):void
        {
            for (var i:int = 0, len:int = removeDisplayList.length; i < len; i++) 
            {
                var data:* = removeDisplayList[i].value;
                if (_listLayout.hasCache(data))
                {
                    var e:IElement = _listLayout.requestElement(0, 0, data);
                    Application.sync.pushThread(pId, new Thread("applyRemoveDiff[remove] "+e.name)
                        .pushRoutine(_listLayout.getTweenRoutineByRemovedStage(data), [e])
                        .pushRoutine(_createRecycleRoutine(data)),
                        false, true);
                }
            }
        }
        
        /**
         * 差分(フィルタリング対象分)を画面に適用する.
         */
        private function _applyFilteringDiff(filteringList:Array, pId:String, length:int):void
        {
            for (var i:int = 0, len:int = filteringList.length; i < len; i++) 
            {
                var data:* = filteringList[i];
                if (_listLayout.hasCache(data))
                {
                    var e:IElement = _listLayout.requestElement(0, 0, filteringList[i]);
                    Application.sync.pushThread(pId, new Thread("applyFilteringDiff[remove] "+e.name)
                        .pushRoutine(_listLayout.getTweenRoutineByRemovedStage(data), [e])
                        .pushRoutine(_createRecycleRoutine(data)),
                        false, true);
                }
            }
        }
        
        /**
         * 差分(並び替え)を画面に適用する.
         */
        private function _refreshElementOrder(diff:ListDiff, beforePosition:Dictionary, moveThread:Thread, addThread:Thread, pId:String):void
        {
            var editedOrigin:Array = diff.editedOrigin;
            for (var i:int = 0, len:int = editedOrigin.length; i < len; i++) 
            {
                var data:* = editedOrigin[ diff.order[i] ];
                var from:Object = beforePosition[data];
                var to:Rectangle;
                var e:IElement;
                var tweenRoutine:Function;
                
                if (data in _simulation.added)
                {
                    tweenRoutine = _listLayout.getTweenRoutineByAddedStage(data);
                    to = _simulation.added[data];
                    e  = _listLayout.requestElement(to.width, to.height, data);
                    //このエレメントはフィルタリング解除されて追加されたか？
                    diff.filteringRestored.indexOf(data) == -1 ?
                        //そうでなければ、並び替え前の位置から移動してきたように見せる
                        addThread.pushRoutine(tweenRoutine, [addDisplay(e), from.x, from.y, to.x, to.y]):
                        //そうであれば、移動なしに表示させる
                        addThread.pushRoutine(tweenRoutine, [addDisplay(e), to.x, to.y]);
                }
                else
                if (data in _simulation.moved)
                {
                    tweenRoutine = _listLayout.getTweenRoutineByMoved(data);
                    to = _simulation.moved[data];
                    e  = _listLayout.requestElement(to.width, to.height, data);
                    moveThread.pushRoutine(tweenRoutine, [e, to.x, to.y]);
                }
                else
                if (data in _simulation.removed && _listLayout.hasCache(data))
                {
                    tweenRoutine = _listLayout.getTweenRoutineByRemovedStage(data);
                    to = _simulation.removed[data];
                    e  = _listLayout.requestElement(0, 0, data);
                    Application.sync.pushThread(pId, new Thread("refreshElementOrder[remove] "+e.name)
                        .pushRoutine(tweenRoutine, [e, to.x, to.y])
                        .pushRoutine(_createRecycleRoutine(data)),
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
                var data:Object = addElementList[i].value;
                if (data in _simulation.contains)
                {
                    var n:int       = addElementList[i].index;
                    var r:Rectangle = _listLayout.calcElementRect(_maxWidth, _maxHeight, n);
                    var e:IElement  = _listLayout.requestElement(r.width, r.height, data);
                    
                    e.x = r.x;
                    e.y = r.y;
                    addThread.pushRoutine(_listLayout.getTweenRoutineByAddedStage(data), [e]);
                }
            }
        }
        
        /**
         * データとエレメントの紐付けを破棄し参照を外す.
         */
        private function _createRecycleRoutine(data:*):Function
        {
            return function(r:Routine, t:Thread):void {
                _listLayout.requestRecycle(data);
                r.scceeded();
            };
        }
        
        private function _refreshSimulationPosition(x:Number, y:Number):void
        {
            parent && parent is ScrollContainer ? _simulation.refresh(x, y): _simulation.refresh(0, 0);
        }
    }
}