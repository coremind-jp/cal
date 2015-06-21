package jp.coremind.control.routine
{
    import jp.coremind.control.Routine;
    import jp.coremind.control.Thread;
    import jp.coremind.data.Progress;

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