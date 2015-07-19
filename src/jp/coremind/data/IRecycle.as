package jp.coremind.data
{
    public interface IRecycle
    {
        function reuseInstance():void;
        function resetInstance():void;
        function destroy():void;
    }
}