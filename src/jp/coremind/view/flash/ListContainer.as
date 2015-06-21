package jp.coremind.view.flash
{
    import flash.geom.Point;
    
    import jp.coremind.control.Process;
    import jp.coremind.control.Thread;
    import jp.coremind.view.IElement;
    import jp.coremind.view.layout.ILayout;

    public class ListContainer extends ElementContainer
    {
        private var
            _childClass:Class,
            _layout:ILayout;
        
        public function ListContainer(layout:ILayout, childClass:Class)
        {
            _layout = layout;
            super();
        }
        
        public function push(elementData:Object):void
        {
            var element:IElement = new _childClass();
            element.bindData(elementData);
            
            var p:Point = _layout.calcPosition(element.elementWidth, element.elementHeight, numChildren, numChildren);
            element.x = p.x;
            element.y = p.y;
            
            addElement(element);
        }
        
        public function filter(filterFunction:Function, pallarel:Boolean, callback:Function = null):void
        {
            var process:Process      = new Process("ListContainer::filter");
            var removeThread:Thread  = new Thread("remove");
            var moveThread:Thread    = new Thread("move");
            
            for (var i:int = 0; i < numChildren; i++) 
            {
                var element:IElement = getChildAt(i) as IElement;
                var n:int = 0;
                
                if (filterFunction(element.data))
                {
                    n++;
                    removeThread.pushRoutine(element.removeTransition(this, element));
                }
                else
                {
                    var p:Point = _layout.calcPosition(element.elementWidth, element.elementHeight, i - n, numChildren);
                    moveThread.pushRoutine(element.mvoeTransition(p.x, p.y));
                }
            }
            
            process
                .pushThread(removeThread, pallarel, true)
                .pushThread(moveThread, pallarel)
                .exec(callback);
        }
        
        public function sort(pallarel:Boolean = true, callback:Function = null, ...args):void
        {
            var dataList:Array = [];
            
            for (var i:int = 0; i < numChildren; i++) 
                dataList.push((getChildAt(i) as IElement).data);
            $.apply(dataList.sort, args);
            
            _move(dataList, pallarel, callback);
        }
        
        public function sortOn(names:*, options:* = 0, pallarel:Boolean = true, callback:Function = null):void
        {
            var dataList:Array = [];
            
            for (var i:int = 0; i < numChildren; i++) 
                dataList.push((getChildAt(i) as IElement).data);
            dataList.sortOn(names, options);
            
            _move(dataList, pallarel, callback);
        }
        
        private function _move(dataList:Array, pallarel:Boolean, callback:Function = null):void
        {
            var moveThread:Thread = new Thread("move");
            
            for (var i:int = 0; i < numChildren; i++) 
            {
                var element:IElement = getChildAt(i) as IElement;
                var to:int = dataList.indexOf(element.data);
                
                if (i != to)
                {
                    var p:Point = _layout.calcPosition(element.elementWidth, element.elementHeight, to, numChildren);
                    moveThread.pushRoutine(element.mvoeTransition(p.x, p.y));
                }
            }
            
            moveThread.exec(callback, pallarel);
        }
    }
}