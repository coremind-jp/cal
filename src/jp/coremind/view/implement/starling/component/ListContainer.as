package jp.coremind.view.implement.starling.component
{
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementInfo;
    import jp.coremind.module.ScrollModule;
    import jp.coremind.module.ScrollbarModule;
    import jp.coremind.storage.transaction.Diff;
    import jp.coremind.storage.transaction.DiffListInfo;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.Container;
    import jp.coremind.view.layout.IListLayout;
    import jp.coremind.view.layout.Layout;
    import jp.coremind.view.layout.LayoutSimulation;
    
    import starling.events.TouchEvent;
    
    public class ListContainer extends Container
    {
        public static const TAG:String = "[ListContainer]";
        Log.addCustomTag(TAG);
        
        private static const PREVIEW_PROCESS:String = "ListContainer::Preview";
        
        private var
            _scrollbar:ScrollbarModule,
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
        
        override protected function _refreshLayout():void
        {
            super._refreshLayout();
            
            _simulation.setDrawableArea(_maxWidth, _maxHeight);
        }
        
        override protected function _updateElementSize():void
        {
            (_info.modules.getModule(ScrollModule) as ScrollModule).refreshContentSize();
            
            if (_scrollbar)
            {
                _scrollbar.updateWidth(_elementWidth, _maxWidth);
                _scrollbar.updateHeight(_elementHeight, _maxHeight);
            }
        }
        
        override public function ready():void
        {
            super.ready();
            
            var r:Rectangle = _listLayout.calcTotalRect(_maxWidth, _maxHeight, _reader.read().length);
            updateElementSize(r.width, r.height);
            updatePosition(x, y);
            enablePointerDeviceControl();
        }
        
        override protected function _onLoadElementInfo():void
        {
            super._onLoadElementInfo();
            
            _listLayout.initialize(_reader);
            
            var list:Array = _reader.read();
            for (var i:int = 0, len:int = list.length; i < len; i++) 
                _simulation.addChild(list[i], _listLayout.calcElementRect(_maxWidth, _maxHeight, i).clone());
        }
        
        override protected function _initializeModules():void
        {
            super._initializeModules();
            
            var scroll:ScrollModule = _info.modules.isUndefined(ScrollModule) ?
                _info.modules.addModule(new ScrollModule(this)) as ScrollModule:
                _info.modules.getModule(ScrollModule) as ScrollModule;
            
            scroll.setScrollVolume(
                _listLayout.getScrollSizeX(_maxWidth),
                _listLayout.getScrollSizeY(_maxHeight));
            
            var p:IElement = parent as IElement;
            if (p && !p.elementInfo.modules.isUndefined(ScrollbarModule))
            {
                _scrollbar = p.elementInfo.modules.getModule(ScrollbarModule) as ScrollbarModule;
                scroll.addListener(_scrollbar.update);
            }
        }
        
        override public function updatePosition(x:Number, y:Number):void
        {
            super.updatePosition(x, y);
            
            var visibleClosure:Function = function(data:*, to:Rectangle, from:Rectangle):void
            {
                var e:IElement = _listLayout.requestElement(to.width, to.height, data);
                e.x = to.x;
                e.y = to.y;
                addDisplay(e);
            };
            
            var invisibleClosure:Function = function(data:*, to:Rectangle, from:Rectangle):void
            {
                removeDisplay(_listLayout.requestElement(0, 0, data));
                _listLayout.requestRecycle(data);
            };
            
            _simulation.updateContainerPosition(x, y);
            _simulation.eachVisible(visibleClosure);
            _simulation.eachInvisible(invisibleClosure);
        }
        
        public function cloneListElement(info:ElementInfo):IElement
        {
            Log.info("cloneListElement info", info);
            var data:Object     = info.reader.read();
            var child:Rectangle = _simulation.findChild(data);
            var splitedId:Array = info.reader.id.split(".");
            return _listLayout.createElement(child.width, child.height, data, splitedId[splitedId.length-1]);
        }
        
        override public function preview(diff:Diff):void
        {
            super.preview(diff);
            
            var pId:String = name + PREVIEW_PROCESS;
            var moveThread:Thread = new Thread("move");
            var addThread:Thread  = new Thread("add");
            var origin:Array = _reader.read();
            var len:int      = _reader.readTransactionResult().length;
            var r:Rectangle  = _listLayout.calcTotalRect(_maxWidth, _maxHeight, len == 0 ? 0: len).clone();
            
            _simulation.beginChildPositionEdit();
            
            _applyRemove(diff, pId);
            
            _applyFilter(diff, pId);
            
            _updateChildrenPosition(diff);
            
            _simulation.updateContainerPosition(x, y);
            
            _refreshElementOrder(diff, moveThread, addThread, pId);
            
            _simulation.endChildPositionEdit();
            
            Application.sync
                .pushThread(pId, addThread,  true, true)
                .pushThread(pId, moveThread, true, true)
                .exec(pId, function (p:Process):void { if (p.result == Status.SCCEEDED) updateElementSize(r.width, r.height); });
        }
        
        override public function commit(diff:Diff):void
        {
            for (var data:* in diff.listInfo.removed)
                _simulation.removeChild(data);
        }
        
        /**
         * 削除差分を画面に適用する.
         */
        private function _applyRemove(diff:Diff, pId:String):void
        {
            _removeChildren(diff.listInfo.removed, diff.listInfo.removeRestored, pId);
        }
        
        /**
         * フィルタリング差分を画面に適用する.
         */
        private function _applyFilter(diff:Diff, pId:String):void
        {
            _removeChildren(diff.listInfo.filtered, diff.listInfo.filterRestored, pId);
        }
        
        private function _removeChildren(removeList:Dictionary, restoreList:Dictionary, pId:String):void
        {
            var data:*;
            
            if (restoreList)
                for (data in restoreList)
                    _simulation.showChild(data);
            
            if (removeList)
            {
                for (data in removeList)
                {
                    _simulation.hideChild(data);
                    _removeElement(pId, data, null);
                }
            }
        }
        
        private function _removeElement(pId:String, data:*, to:Rectangle):void
        {
            if (_listLayout.hasCache(data))
            {
                var e:IElement = _listLayout.requestElement(0, 0, data);
                var tweenRoutine:Function = _listLayout.getTweenRoutineByRemovedStage(data);
                var params:Array = to ? [e, to.x, to.y]: [e];
                //Log.info("[EO] remove", e.elementInfo, to, data);
                
                Application.sync.pushThread(pId, new Thread("applyDiff[remove] "+e.name)
                    .pushRoutine(_listLayout.getTweenRoutineByRemovedStage(data), params)
                    .pushRoutine(_createRecycleRoutine(data)),
                    false, true);
            }
        }
        
        /**
         * 可視状態に関係なくデータと紐付く全てのエレメント位置座標を最新の並び順に更新する.
         * 更新前の座標を戻り値として返す。
         */
        private function _updateChildrenPosition(diff:Diff):void
        {
            var i:int, len:int, r:Rectangle, e:IElement;
            var order:Vector.<int> = diff.listInfo.order;
            var edited:Array = _reader.readTransactionResult();
            
            if (order)
            {
                for (i = 0, len = order.length; i < len; i++) 
                {
                    r = _listLayout.calcElementRect(_maxWidth, _maxHeight, i);
                    
                    var n:int = order[i];
                    _simulation.hasChild(edited[n]) ?
                        _simulation.updateChildPosition(edited[n], r):
                        _simulation.addChild(edited[n], r);
                    
                    if (_listLayout.hasCache(edited[n]))
                    {
                        e = _listLayout.requestElement(_maxWidth, _maxHeight, edited[n]);
                        if (int(e.name) != n) e.changeIdSuffix(n.toString());
                    }
                }
            }
            else
            {
                for (i = 0, len = edited.length; i < len; i++) 
                {
                    r = _listLayout.calcElementRect(_maxWidth, _maxHeight, i);
                    
                    _simulation.hasChild(edited[i]) ?
                        _simulation.updateChildPosition(edited[i], r):
                        _simulation.addChild(edited[i], r);
                    
                    if (_listLayout.hasCache(edited[i]))
                    {
                        e = _listLayout.requestElement(_maxWidth, _maxHeight, edited[i]);
                        if (int(e.name) != i) e.changeIdSuffix(i.toString());
                    }
                }
            }
        }
        
        /**
         * 差分(並び替え)を画面に適用する.
         */
        private function _refreshElementOrder(diff:Diff, moveThread:Thread, addThread:Thread, pId:String):void
        {
            var readers:Array = [];
            var createClosure:Function = function(data:*, index:int, to:Rectangle, from:Rectangle):void
            {
                var e:IElement = _listLayout.requestElement(to.width, to.height, data, index);
                var tweenRoutine:Function = _listLayout.getTweenRoutineByAddedStage(data);
                var info:DiffListInfo = diff.listInfo;
                /*
                Log.info("[EO] add",
                    "filterRestore", info.filterRestored && data in info.filterRestored,
                    "removeRestore", info.removeRestored && data in info.removeRestored,
                    from, "=>", to, e.elementInfo, data);
                */
                info.filterRestored && data in info.filterRestored ||
                info.removeRestored && data in info.removeRestored ?
                    addThread.pushRoutine(tweenRoutine, [addDisplay(e), to.x, to.y]):
                    addThread.pushRoutine(tweenRoutine, [addDisplay(e), from.x, from.y, to.x, to.y]);
            };
            
            var visibleClosure:Function = function(data:*, index:int, to:Rectangle, from:Rectangle):void
            {
                var e:IElement = _listLayout.requestElement(to.width, to.height, data);
                var tweenRoutine:Function = _listLayout.getTweenRoutineByMoved(data);
                
                //Log.info("[EO] move", from, "=>", to, e.elementInfo, data);
                moveThread.pushRoutine(tweenRoutine, [e, to.x, to.y]);
            };
            
            var invisibleClosure:Function = function(data:*, index:int, to:Rectangle, from:Rectangle):void
            {
                _removeElement(pId, data, to);
            };
            
            var i:int, len:int;
            var order:Vector.<int> = diff.listInfo.order;
            var edited:Array = _reader.readTransactionResult();
            if (order)
                for (i = 0, len = order.length; i < len; i++) 
                    _simulation.switchClosure(edited[ order[i] ], order[i], createClosure, visibleClosure, invisibleClosure);
            else
                for (i = 0, len = edited.length; i < len; i++) 
                    _simulation.switchClosure(edited[i], i, createClosure, visibleClosure, invisibleClosure);
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
        
        //このクラスインスタンスのTouchハンドラは開始だけ取得できれば良いので既存の実装を継承させない.
        override public function enablePointerDeviceControl():void
        {
            touchable = true;
            addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        override public function disablePointerDeviceControl():void
        {
            touchable = false;
            removeEventListener(TouchEvent.TOUCH, _onTouch);
        }
        override protected function began():void
        {
            (_info.modules.getModule(ScrollModule) as ScrollModule).beginPointerDeviceListening();
        }
    }
}