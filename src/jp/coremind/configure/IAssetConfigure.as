package jp.coremind.configure
{
    import flash.geom.Rectangle;

    public interface IAssetConfigure
    {
        function getAtlasId(id:String):String;
        function getPaintableArea(id:String):Rectangle;
        function getBitmapFontConfigureList(id:String):Array;
        function getPainterList(id:String):Array;
        function getTextureMagnificationScale():uint;
        function getAllocateIdList(viewName:String):Array;
    }
}