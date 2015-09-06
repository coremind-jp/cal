package jp.coremind.view.implement.starling.component
{
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import jp.coremind.model.Diff;
    import jp.coremind.model.ListDiff;
    import jp.coremind.model.TransactionLog;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;
    import jp.coremind.utility.process.Process;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.implement.starling.ElementContainer;
    import jp.coremind.view.layout.Align;
    import jp.coremind.view.layout.ILayout;
    import jp.coremind.view.layout.LayoutCalculator;
    import jp.coremind.view.layout.LayoutSimulation;
    
    public class ListContainer extends ElementContainer
    {
        public static const TAG:String = "[ListContainer]";
        //Log.addCustomTag(TAG);
        
        private static const PREVIEW_PROCESS:String = "ListContainer::Preview";
        private static const REFRESH_PROCESS:String = "ListContainer::Refresh";
        
        private var
            _layout:ILayout,
            _simulation:LayoutSimulation;
        
        /**
         * 配列データをリスト表示オブジェクトとして表示するコンテナクラス.
         */
        public function ListContainer(
            layout:ILayout,
            layoutCalculator:LayoutCalculator,
            controllerClass:Class = null,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, controllerClass, backgroundBuilder);
            
            _layout = layout;
            _simulation = new LayoutSimulation();
        }
        
        override public function initialize(storageId:String = null):void
        {
            super.initialize(storageId);
            
            _layout.initialize(_reader);
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            Log.info("destory ListContainer", withReference);
            
            _simulation.destroy();
            
            if (withReference)
                _layout.destroy(withReference);
            _layout = null;
            
            super.destroy(withReference);
        }
        
        override public function preview(plainDiff:Diff):void
        {
            var previewProcess:String = name + " " + PREVIEW_PROCESS;
            var diff:ListDiff     = plainDiff as ListDiff;
            var moveThread:Thread = new Thread("move");
            var addThread:Thread  = new Thread("add");
            var len:int = diff.editedOrigin.length;
            var beforePosition:Dictionary;
            var r:Rectangle = _layout.calcTotalRect(_maxWidth, _maxHeight, len == 0 ? 0: len).clone();
            
            if (len > 500)//リスト長が2500以上の場合待機時間を設ける
                controller.syncProcess.pushThread(
                    previewProcess, new Thread("sort waiting").pushRoutine(
                        $.loop.highResolution.createWaitProcess(len / 30)//リスト長の20分の1を待機時間にする
                    ),
                    false,
                    false);
            
            beforePosition = _updateElementPosition(diff);
            
            _applyRemoveDiff(diff.removed, previewProcess);
            
            _applyFilteringDiff(diff.filtered, previewProcess);
            
            _refreshElementOrder(diff, beforePosition, moveThread, addThread, previewProcess);
            
            _applyAddDiff(diff.added, addThread, len);
            
            controller.syncProcess
                .pushThread(previewProcess, addThread,  true, true)
                .pushThread(previewProcess, moveThread, true, true)
                .exec(previewProcess, function (p:Process):void {
                    if (p.result === Status.SCCEEDED) updateElementSize(r.width, r.height);
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
                _simulation.addChild(diff.added[i].value, _layout.calcElementRect(_maxWidth, _maxHeight, editedOrigin.length - len + i).clone());
        }
        
        override public function initializeChildrenLayout():void
        {
            _simulation.setDrawableArea(_maxWidth, _maxHeight);
            
            var list:Array = _reader.read();
            for (var i:int = 0, len:int = list.length; i < len; i++) 
                _simulation.addChild(list[i], _layout.calcElementRect(_maxWidth, _maxHeight, i).clone());
            _refreshSimulationPosition(x, y);
            
            var added:Dictionary = _simulation.added;
            for (var key:* in added)
            {
                var rect:Rectangle = added[key];
                var e:IElement = _layout.requestElement(rect.width, rect.height, key);
                e.x = rect.x;
                e.y = rect.y;
                addElement(e);
            }
            
            var r:Rectangle = _layout.calcTotalRect(_maxWidth, _maxHeight, len);
            updateElementSize(r.width, r.height);
        }
        
        override public function refreshChildrenLayout():void
        {
            if (!_requireRefresh()) return;
            
            var e:IElement;
            var to:Rectangle;
            var data:*;
            
            for (data in _simulation.removed) 
            {
                if (_layout.hasCache(data))
                {
                    removeElement(_layout.requestElement(0, 0, data));
                    _layout.requestRecycle(data);
                }
            }
            
            for (data in _simulation.added) 
            {
                to = _simulation.added[data];
                e  = _layout.requestElement(to.width, to.height, data);
                e.x = to.x;
                e.y = to.y;
                addElement(e);
            }
        }
        
        /**
         * 現在のコンテナの座標で描画領域を更新した際に内包する子が追加、または削除され子の描画状態を更新する必要があるかを示す値を返す.
         */
        private function _requireRefresh():Boolean
        {
            var invokable:Boolean = false;
            var data:*;
            
            _refreshSimulationPosition(x, y);
            
            for (data in _simulation.added)   { return true; }
            for (data in _simulation.removed) { return true; }
            return false;
        }
        
        /**
         * 可視状態に関係なくデータと紐付く全てのエレメント位置座標を最新の並び順に更新する.
         * 更新前の座標を戻り値として返す。
         */
        private function _updateElementPosition(diff:ListDiff):Dictionary
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
                var s:Rectangle = _layout.calcElementRect(_maxWidth, _maxHeight, j);
                r.x = s.x;
                r.y = s.y;
            }
            _refreshSimulationPosition(x, y);
            
            return beforePosition;
        }
        
        /**
         * 差分(削除分)を画面に適用する.
         */
        private function _applyRemoveDiff(removeElementList:Vector.<TransactionLog>, processName:String):void
        {
            for (var i:int = 0, len:int = removeElementList.length; i < len; i++) 
            {
                if (_layout.hasCache(removeElementList[i].value))
                {
                    var e:IElement = _layout.requestElement(0, 0, removeElementList[i].value);
                    controller.syncProcess.pushThread(processName, new Thread("remove"+e)
                        .pushRoutine(e.removeTransition(this, e))
                        .pushRoutine(_createRecycleRoutine(removeElementList[i].value)),
                        false, true);
                }
            }
        }
        
        /**
         * 差分(フィルタリング対象分)を画面に適用する.
         */
        private function _applyFilteringDiff(filteringList:Array, processName:String):void
        {
            for (var i:int = 0, len:int = filteringList.length; i < len; i++) 
            {
                if (_layout.hasCache(filteringList[i]))
                {
                    var e:IElement = _layout.requestElement(0, 0, filteringList[i]);
                    controller.syncProcess.pushThread(processName, new Thread("remove"+e)
                        .pushRoutine(e.removeTransition(this, e))
                        .pushRoutine(_createRecycleRoutine(filteringList[i])),
                        false, true);
                }
            }
        }
        
        /**
         * 差分(並び替え)を画面に適用する.
         */
        private function _refreshElementOrder(diff:ListDiff, beforePosition:Dictionary, moveThread:Thread, addThread:Thread, processName:String):void
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
                    e  = _layout.requestElement(to.width, to.height, data);
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
                    e  = _layout.requestElement(to.width, to.height, data);
                    moveThread.pushRoutine(e.mvoeTransition(e, to.x, to.y));
                }
                else
                if (data in _simulation.removed && _layout.hasCache(data))
                {
                    to = _simulation.removed[data];
                    e  = _layout.requestElement(0, 0, data);
                    controller.syncProcess.pushThread(processName, new Thread("remove"+e)
                        .pushRoutine(e.removeTransition(this, e, to.x, to.y))
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
                if (addElementList[i].value in _simulation.contains)
                {
                    var o:int       = addElementList[i].key;
                    var r:Rectangle = _layout.calcElementRect(_maxWidth, _maxHeight, o);
                    var e:IElement  = _layout.requestElement(r.width, r.height, addElementList[i].value);
                    
                    e.x = r.x;
                    e.y = r.y;
                    addThread.pushRoutine(e.addTransition(this, e));
                }
            }
        }
        
        /**
         * データとエレメントの紐付けを破棄し参照を外す.
         */
        private function _createRecycleRoutine(data:*):Function
        {
            return function(r:Routine, t:Thread):void {
                _layout.requestRecycle(data);
                r.scceeded();
            };
        }
        
        private function _refreshSimulationPosition(x:Number, y:Number):void
        {
            parent && parent is ScrollContainer ? _simulation.refresh(x, y): _simulation.refresh(0, 0);
        }
    }
}