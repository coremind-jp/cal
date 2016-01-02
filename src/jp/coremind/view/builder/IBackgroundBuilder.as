package jp.coremind.view.builder
{
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IStretchBox;

    public interface IBackgroundBuilder
    {
        function build(parent:ICalSprite):IStretchBox;
    }
}