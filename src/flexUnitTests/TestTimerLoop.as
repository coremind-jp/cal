package flexUnitTests
{
    import flash.utils.getTimer;
    import flash.utils.setTimeout;
    
    import jp.coremind.core.Thread;
    import jp.coremind.data.Progress;
    import jp.coremind.utility.Log;
    
    public class TestTimerLoop
    {		
        [Before]
        public function setUp():void
        {
        }
        
        [After]
        public function tearDown():void
        {
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function testPushHandler():void
        {
            var _repeateNum:int = 5;
            Log.debug("TimerLoop pushHander(250msec)."+getTimer());
            $.loop.highResolution.pushHandler(
                250,
                function(p:Progress):void
                {
                    Log.debug("TimerLoop pushHander called complete.", getTimer(), p.rate);
                },
                function(p:Progress):void
                {
                    Log.debug("TimerLoop pushHander called update.", getTimer(), p.rate);
                });
        }
        
        [Test]
        public function testSetInterval():void
        {
            var _repeateNum:int = 5;
            Log.debug("TimerLoop setTimeout(5times).", getTimer());
            $.loop.lowResolution.setInterval(function(elapsed:int, a:int, b:String, c:Array):Boolean
            {
                Log.debug("TimerLoop called interval function "+_repeateNum--);
                Log.info("dump arguments", arguments);
                return _repeateNum == 0;
            }, 95, "str args", [9, 8, 7])
        }
        
        [Test]
        public function testTerminate():void
        {
            setTimeout(function():void
            {
                var _repeateNum:int = 5;
                Log.debug("TimerLoop terminate(1000msec later).", getTimer());
                $.loop.lowResolution.pushHandler(
                    1000,
                    function(now:int):void
                    {
                        Log.debug("TimerLoop pushHander called terminate complete.", getTimer());
                    },
                    function(now:int):void
                    {
                        Log.debug("TimerLoop pushHander called terminate update.", getTimer());
                    });
                
                setTimeout($.loop.lowResolution.terminate, 500);
            }, 1500);
        }
        
        [Test]
        public function testCreateWaitProcess():void
        {
            new Thread("TimerLoop wait process start(1sec)."+getTimer()).pushRoutine(
                $.loop.lowResolution.createWaitProcess(1000)
            ).exec(function(t:Thread):void {
                Log.debug("TimerLoop wait process stop"+getTimer());
            });
        }
        
        [Test]
        public function testSetTimeout():void
        {
            Log.debug("TimerLoop setTimeout(1sec)."+getTimer());
            $.loop.lowResolution.setTimeout(1000, function(a:int, b:String, c:Array):Boolean
            {
                Log.debug("TimerLoop setTimeout stop"+getTimer());
                Log.info("dump arguments", arguments);
            }, 95, "str args", [9, 8, 7])
        }
    }
}