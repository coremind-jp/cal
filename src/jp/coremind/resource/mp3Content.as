package jp.coremind.resource
{
    import flash.media.Sound;
    import flash.utils.ByteArray;
    
    public class mp3Content implements IByteArrayContent
    {
        public static var NOT_FOUND_SOUNDE:Sound = new Sound();
        
        public function mp3Content()
        {
        }
        
        public function get fileExtention():String
        {
            return "mp3";
        }
        
        public function extract(f:Function, binary:ByteArray):void
        {
            var sound:Sound = new Sound();
            sound.loadCompressedDataFromByteArray(binary, binary.length);
            $.call(f, sound);
        }
        
        public function clone(source:*):*
        {
            return source;
        }
        
        public function createFailedContent():*
        {
            return NOT_FOUND_SOUNDE;
        }
    }
}