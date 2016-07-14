package jp.coremind.controller
{
    import flash.geom.Rectangle;
    
    import jp.coremind.core.ElementPathParser;
    import jp.coremind.core.IDragDropControl;
    import jp.coremind.utility.Log;

    public class DragAndDropConfigure
    {
        public var
            /** ドラッグドロップの一連のイベントをポーリングする先となるControllerクラス */
            controllerClass:Class,
            /** ドロップ領域のリスト(elementIdによる指定) */
            dropAreaList:Array,
            /** ドラッグ領域 */
            dragArea:Rectangle,
            /** 押下からドラッグ開始までの遅延ms*/
            dragDelay:int,
            /** ドラッグしたオブジェクトがドロップ可能領域に入ってからロールオーバー処理が発生するまでの遅延ms*/
            rolloverDelay:int,
            /** ドラッグしたオブジェクトがドロップ可能領域に入った際にその領域に吸着するかを示す値 */
            absorbWhenRollover:Boolean,
            /** ドラッグしたオブジェクトがドロップ可能領域に入った際にドラッグ中の表示オブジェクトを非表示するかを示す値 */
            invisibleWhenRollover:Boolean;
        
        public function DragAndDropConfigure(
            controllerClass:Class,
            dropAreaList:Array,
            dragArea:Rectangle,
            dragDelay:int = 0,
            rolloverDelay:int = 0,
            invisibleWhenRollover:Boolean = false,
            absorbWhenRollover:Boolean = true)
        {
            if ($.isImplements(controllerClass, IDragDropControl))
            {
                this.controllerClass       = controllerClass;
                this.dropAreaList          = _convertDropAreaList(dropAreaList);
                this.dragArea              = dragArea;
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