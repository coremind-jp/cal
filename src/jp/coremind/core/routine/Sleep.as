package jp.coremind.core.routine
{
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.utility.data.Progress;

    public class Sleep
    {
        public static function create(time:int):Function
        {
            return function(r:Routine, t:Thread):void
            {
                $.loop.lowResolution.pushHandler(
                    time,
                    function(p:Progress):void { r.scceeded("Sleep complete."); },
                    function(p:Progress):void { r.updateProgress(p.min, p.max, p.now); });
            }
        }
    }
}