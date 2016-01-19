package jp.coremind.view.implement.starling.component
{
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementEvent;
    import jp.coremind.event.ElementInfo;
    import jp.coremind.model.module.ScrollModule;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.model.transaction.DiffListInfo;
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
                
                (_info.modules.getModule(ScrollModule) as ScrollModule).refreshContentSize();
                
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
        
        override protected function _initializeModules():void
        {
            super._initializeModules();
            
            if (_info.modules.isUndefined(ScrollModule))
                _info.modules.addModule(new ScrollModule(this));
            
            (_info.modules.getModule(ScrollModule) as ScrollModule).setScrollVolume(
                _listLayout.getScrollSizeX(_maxWidth),
                _listLayout.getScrollSizeY(_maxHeight));
        }
        
        override public function updatePosition(x:Number, y:Number):void
        {
            super.updatePosition(x, y);
            
            _updateSimulation(x, y);
            
            _simulation.eachVisible(function(data:*, to:Rectangle, from:Rectangle):void
            {
                var e:IElement = _listLayout.requestElement(to.width, to.height, data);
                e.x = to.x;
                e.y = to.y;
                addDisplay(e);
            });
            
            _simulation.eachInvisible(function(data:*, to:Rectangle, from:Rectangle):void
            {
                if (_listLayout.hasCache(data))
                {
                    removeDisplay(_listLayout.requestElement(0, 0, data));
                    _listLayout.requestRecycle(data);
                }
            });
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
            _listUpdate(diff);
        }
        
        override public function commit(diff:Diff):void
        {
            super.commit(diff);
            //_listUpdate(diff);
        }
        
        private function _listUpdate(diff:Diff):void
        {
            var pId:String = name + PREVIEW_PROCESS;
            var moveThread:Thread = new Thread("move");
            var addThread:Thread  = new Thread("add");
            var len:int = diff.editedOrigin.length;
            var r:Rectangle = _listLayout.calcTotalRect(_maxWidth, _maxHeight, len == 0 ? 0: len).clone();
            var origin:Array = _reader.read();
            
            _simulation.beginChildPositionEdit();
            
            _applyRemoveAndFilteringDiff(diff, pId);
            
            _updateChildrenPosition(diff);
            
            _updateSimulation(x, y);
            
            _refreshElementOrder(diff, moveThread, addThread, pId);
            
            _simulation.endChildPositionEdit();
            
            Application.sync
                .pushThread(pId, addThread,  true, true)
                .pushThread(pId, moveThread, true, true)
                .exec(pId, function (p:Process):void { if (p.result == Status.SCCEEDED) updateElementSize(r.width, r.height); });
        }
        
        /**
         * 差分(削除, フィルタリング, フィルタリング解除対象分)を画面に適用する.
         */
        private function _applyRemoveAndFilteringDiff(diff:Diff, pId:String):void
        {
            var data:*;
            
            if (diff.listInfo.filteringRestored)
            {
                for (data in diff.listInfo.filteringRestored)
                {
                    //Log.custom(TAG, "filteringRestored", data);
                    _simulation.showChild(data);
                }
            }
            
            if (diff.listInfo.filtered)
            {
                for (data in diff.listInfo.filtered)
                {
                    //Log.custom(TAG, "filtered", data);
                    _simulation.hideChild(data);
                    _removeElement(pId, data, null);
                }
            }
            
            for (data in diff.listInfo.removed)
            {
                //Log.custom(TAG, "applyRemoveDiff", data);
                _simulation.removeChild(data);
                _removeElement(pId, data, null);
            }
        }
        
        /**
         * 可視状態に関係なくデータと紐付く全てのエレメント位置座標を最新の並び順に更新する.
         * 更新前の座標を戻り値として返す。
         */
        private function _updateChildrenPosition(diff:Diff):void
        {
            var edited:Array = diff.editedOrigin;
            var i:int, len:int, r:Rectangle, e:IElement;
            var order:Vector.<int> = diff.listInfo.order;
            
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
         * 差分(並び替え)を画面に適用する.
         */
        private function _refreshElementOrder(diff:Diff, moveThread:Thread, addThread:Thread, pId:String):void
        {
            var createClosure:Function = function(data:*, to:Rectangle, from:Rectangle):void
            {
                var e:IElement = _listLayout.requestElement(to.width, to.height, data);
                var tweenRoutine:Function = _listLayout.getTweenRoutineByAddedStage(data);
                var info:DiffListInfo = diff.listInfo;
                
                //Log.info("[EO] add", e.elementInfo, from, "=>", to, data);
                //このエレメントはフィルタリング解除されて追加されたか？
                info.filteringRestored && data in info.filteringRestored ?
                    addThread.pushRoutine(tweenRoutine, [addDisplay(e), to.x, to.y])://そうであれば、移動なしに表示させる
                    addThread.pushRoutine(tweenRoutine, [addDisplay(e), from.x, from.y, to.x, to.y]);//そうでなければ、並び替え前の位置から移動してきたように見せる
            };
            
            var visibleClosure:Function = function(data:*, to:Rectangle, from:Rectangle):void
            {
                var e:IElement = _listLayout.requestElement(to.width, to.height, data);
                var tweenRoutine:Function = _listLayout.getTweenRoutineByMoved(data);
                
                //Log.info("[EO] move", e.elementInfo, from, "=>", to, data);
                moveThread.pushRoutine(tweenRoutine, [e, to.x, to.y]);
            };
            
            var invisibleClosure:Function = function(data:*, to:Rectangle, from:Rectangle):void
            {
                _removeElement(pId, data, to);
            };
            
            var i:int, len:int;
            var order:Vector.<int> = diff.listInfo.order;
            if (order)
                for (i = 0, len = order.length; i < len; i++) 
                    _simulation.switchClosure(diff.editedOrigin[ order[i] ], createClosure, visibleClosure, invisibleClosure);
            else
                for (i = 0, len = diff.editedOrigin.length; i < len; i++) 
                    _simulation.switchClosure(diff.editedOrigin[i], createClosure, visibleClosure, invisibleClosure);
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
        
        private function _updateSimulation(x:Number, y:Number):Boolean
        {
            return parent is ScrollContainer ?
                _simulation.updateContainerPosition(x, y):
                _simulation.updateContainerPosition(0, 0);
        }
    }
}