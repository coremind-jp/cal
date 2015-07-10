package jp.coremind.utility
{
    public interface IRecycle
    {
        function reuseInstance():void;
        function resetInstance():void;
        function destroy():void;
    }
}