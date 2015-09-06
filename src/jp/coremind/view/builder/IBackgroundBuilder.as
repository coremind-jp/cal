package jp.coremind.view.builder
{
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IStretchBox;

    public interface IBackgroundBuilder
    {
        function build(parent:IElement):IStretchBox;
    }
}