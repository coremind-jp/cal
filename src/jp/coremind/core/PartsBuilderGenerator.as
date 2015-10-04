package jp.coremind.core
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
    import jp.coremind.view.builder.ImageBuilder;
    import jp.coremind.view.layout.Size;

    public class PartsBuilderGenerator
    {
        private var
            _temp:IDisplayObjectBuilder;
        
        public function PartsBuilderGenerator() {}
        
        public function req(command:String):IDisplayObjectBuilder
        {
            return null
        }
        /*
        private function _parseCommand(commndLine:String):IDisplayObjectBuilder
        {
            var cmd:Array = commndLine.split(".");
            if (cmd.length < 5)
            {
                Log.error("[PartsBuilderGenerator] wrong command line.", commndLine);
                return null;
            }
            
            var builder:String = cmd[0];
            switch (builder)
            {
                case "i":
                {
                    return 
                    break;
                }
                    
                default:
                {
                    break;
                }
            }
            
            
            return null;
        }
        */
    }
}