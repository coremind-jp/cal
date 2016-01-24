package jp.coremind.view.builder.parts
{
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IStretchBox;

    public interface IBackgroundBuilder
    {
        function build(parent:ICalSprite):IStretchBox;
    }
}