package flexUnitTests
{
    import flash.utils.getTimer;
    import flash.utils.setTimeout;
    
    import jp.coremind.control.Thread;
    import jp.coremind.data.Progress;
    import jp.coremind.utility.Log;
    
    public class TestFrameLoop
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
        public function testTerminate():void
        {
            setTimeout(function():void
            {
                setTimeout($.loop.framePreProcess.terminate, 100);
                Log.debug("FrameLoop terminate.", getTimer());
                
                $.loop.framePreProcess.pushHandler(
                    5,
                    function(now:int):void
                    {
                        Log.debug("FrameLoop pushHander called terminate complete.", getTimer());
                    },
                    function(now:int):void
                    {
                        Log.debug("FrameLoop pushHander called terminate update.", getTimer());
                    });
            }, 10000);
        }
        
        [Test]
        public function testPushHandler():void
        {
            setTimeout(function():void
            {
                Log.debug("FrameLoop pushHander.");
                $.loop.framePreProcess.pushHandler(
                    5,
                    function(p:Progress):void
                    {
                        Log.debug("FrameLoop pushHander called complete.", p.rate);
                    },
                    function(p:Progress):void
                    {
                        Log.debug("FrameLoop pushHander called update.", p.rate);
                    });
            }, 2000);
        }
        
        [Test]
        public function testSetInterval():void
        {
            setTimeout(function():void
            {
                var _repeateNum:int = 5;
                Log.debug("FrameLoop setInterval(5times).", getTimer());
                $.loop.framePreProcess.setInterval(function(a:int, b:String, c:Array):Boolean
                {
                    Log.debug("FrameLoop called interval function "+_repeateNum--);
                    Log.info("dump arguments", arguments);
                    return _repeateNum == 0;
                }, 95, "str args", [9, 8, 7])
            }, 4000);
        }
        
        [Test]
        public function testCreateWaitProcess():void
        {
            setTimeout(function():void
            {
                Log.debug("FrameLoop wait process start"+getTimer());
                new Thread("").pushRoutine(
                    $.loop.framePreProcess.createWaitProcess(5)
                ).exec(function(res:Array):void {
                    Log.debug("FrameLoop wait process stop"+getTimer());
                });
            }, 6000);
        }
        
        [Test]
        public function testSetTimeout():void
        {
            setTimeout(function():void
            {
                Log.debug("FrameLoop setTimeout."+getTimer());
                $.loop.framePreProcess.setTimeout(5, function(a:int, b:String, c:Array):Boolean
                {
                    Log.debug("FrameLoop setTimeout stop"+getTimer());
                    Log.info("dump arguments", arguments);
                }, 95, "str args", [9, 8, 7])
            }, 8000);
        }
    }
}