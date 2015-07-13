package jp.coremind.resource
{
    public class EmbedResourceDifine
    {
        private static const PATH:String = "";
        
        [Embed(source = "../../../../libs/images/grid.png")]
        public static const PNG_GRID:Class;
        
        [Embed(source="../../../../libs/images/grid.xml", mimeType="application/octet-stream")]
        public static const XML_GRID:Class;
    }
}