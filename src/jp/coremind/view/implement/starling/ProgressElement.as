package jp.coremind.view.implement.starling
{
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
    import jp.coremind.view.layout.Layout;
    
    public class ProgressElement extends Container
    {
        public function ProgressElement(layoutCalculator:Layout, backgroundBuilder:IBackgroundBuilder=null)
        {
            super(layoutCalculator, backgroundBuilder);
        }
    }
}