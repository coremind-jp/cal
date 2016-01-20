package jp.coremind.core
{
    import jp.coremind.utility.Log;

    public class DragAndDropConfigure
    {
        public var
            controllerClass:Class,
            dropAreaList:Array,
            dragDelay:int,
            rolloverDelay:int,
            absorbWhenRollover:Boolean,
            invisibleWhenRollover:Boolean;
        
        public function DragAndDropConfigure(
            controllerClass:Class,
            dropAreaList:Array,
            dragDelay:int = 0,
            rolloverDelay:int = 0,
            invisibleWhenRollover:Boolean = false,
            absorbWhenRollover:Boolean = true)
        {
            if ($.isImplements(controllerClass, IDragDropControl))
            {
                this.controllerClass       = controllerClass;
                this.dropAreaList          = _convertDropAreaList(dropAreaList);
                this.dragDelay             = dragDelay;
                this.rolloverDelay         = rolloverDelay;
                this.absorbWhenRollover    = absorbWhenRollover;
                this.invisibleWhenRollover = invisibleWhenRollover;
                Log.info(dropAreaList);
            }
            else Log.error("DragAndDropConfigure initialize failed.", controllerClass, " require implements IDragDropControl interface.");
        }
        
        private function _convertDropAreaList(list:Array):Array
        {
            for (var i:int = 0; i < list.length; i++) 
                list[i] is Array ?
                    list[i] = new ElementPathParser()
                    .initialize(list[i].shift(), list[i].shift(), list[i].join(".")):
                    list.splice(i--, 1);
            
            return list;
        }
    }
}