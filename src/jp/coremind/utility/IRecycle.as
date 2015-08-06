package jp.coremind.utility
{
    import jp.coremind.model.StorageModelReader;

    public interface IRecycle
    {
        function initialize(reader:StorageModelReader):void;
        function reset():void;
        function destroy():void;
    }
}