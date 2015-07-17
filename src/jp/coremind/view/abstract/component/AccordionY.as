package jp.coremind.view.abstract.component
{
    import jp.coremind.view.abstract.IBox;

    /**
     * Accordionクラスの可変長方向をY軸基準で実装したクラス.
     */
    public class AccordionY extends Accordion
    {
        public function AccordionY()
        {
            super();
        }
        
        override protected function _updateBox(child:IBox, childSize:Number, childPosition:Number):void
        {
            child.y = childPosition;
            child.height = childSize;
        }
    }
}