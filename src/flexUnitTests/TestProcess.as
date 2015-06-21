package flexUnitTests
{
    import flash.utils.getTimer;
    import flash.utils.setTimeout;
    
    import mx.events.FlexEvent;
    
    import flexunit.framework.Assert;
    
    import jp.coremind.control.Process;
    import jp.coremind.control.Routine;
    import jp.coremind.control.Thread;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.Status;
    
    import org.flexunit.assertThat;
    import org.flexunit.async.Async;
    import org.hamcrest.object.equalTo;
    
    public class TestProcess
    {		
        private static const _assertDelay:int = 1500;
        
        private var _p:Process;
        private var _asyncHandler:Function;
        private var _startTime:int;
        
        [Before]
        public function setUp():void
        {
            _startTime = getTimer();
        }
        
        [After]
        public function tearDown():void
        {
            _p = null;
            _asyncHandler = null;
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        private function _doAsyncTest(p:Process):void
        {
            _p = p;
            _asyncHandler();
        }
        
        private function _timeout(f:Function, delay:int):void
        {
            setTimeout(function():void {
                Log.info(getTimer() - _startTime);
                f();
            }, delay);
        }
        
        [Test(async)]
        public function testExecSync():void
        {
            var delay:int = 80;
            
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_p.name, equalTo("TestExecSync"));
                    assertThat(_p.result, equalTo(Status.SCCEEDED));
                    assertThat(_p.phase, equalTo(Status.FINISHED));
                    assertThat(_p.progress, equalTo(1));
                    
                    var k:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"];
                    for (var i:int = 0; i < k.length; i++) 
                        assertThat(_p.readData(k[i]), equalTo(i));
                }, _assertDelay);
            
            new Process("TestExecSync")
                .pushThread(new Thread("serial thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("a", 0);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        assertThat(t.readData("a"), equalTo(0));
                        r.writeData("b", 1);
                        _timeout(r.scceeded, delay);//160
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        assertThat(t.readData("b"), equalTo(1));
                        r.writeData("c", 2);
                        _timeout(r.scceeded, delay);//240
                    }), false)
                //serial to parallel
                .pushThread(new Thread("parallel thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        assertThat(t.readData("c"), equalTo(2));
                        r.writeData("d", 3);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("e", 4);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("f", 5);
                        _timeout(r.scceeded, delay);//320
                    }), true)
                //parallel to parallel
                .pushThread(new Thread("parallel thread b")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        assertThat(t.readData("d"), equalTo(3));
                        assertThat(t.readData("e"), equalTo(4));
                        assertThat(t.readData("f"), equalTo(5));
                        r.writeData("g", 6);
                        _timeout(r.scceeded, delay);//400
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("h", 7);
                        _timeout(r.scceeded, delay);//400
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("i", 8);
                        _timeout(r.scceeded, delay);//400
                    }), true)
                //parallel to serial
                .pushThread(new Thread("serial thread b")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("j", 9);
                        _timeout(r.scceeded, delay);//480
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("k", 10);
                        _timeout(r.scceeded, delay);//560
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("l", 11);
                        _timeout(r.scceeded, delay);//640
                    }), false)
                //serial to serial
                .pushThread(new Thread("serial thread c")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("m", 12);
                        _timeout(r.scceeded, delay);//720
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("n", 13);
                        _timeout(r.scceeded, delay);//800
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("o", 14);
                        _timeout(r.scceeded, delay);//880
                    }), false)
                .exec(_doAsyncTest);
        }
        
        [Test(async)]
        public function testExecAsync():void
        {
            var delay:int = 80;
            
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_p.name, equalTo("TestExecAsync"));
                    assertThat(_p.result, equalTo(Status.SCCEEDED));
                    assertThat(_p.phase, equalTo(Status.FINISHED));
                    assertThat(_p.progress, equalTo(1));
                    
                    var k:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"];
                    for (var i:int = 0; i < k.length; i++) 
                        assertThat(_p.readData(k[i]), equalTo(i));
                }, _assertDelay);
            
            new Process("TestExecAsync")
                .pushThread(new Thread("serial thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("a", 0);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("b", 1);
                        _timeout(r.scceeded, delay);//160
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("c", 2);
                        _timeout(r.scceeded, delay);//240
                    }), false, true)
                //serial to parallel
                .pushThread(new Thread("parallel thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("d", 3);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("e", 4);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("f", 5);
                        _timeout(r.scceeded, delay);//80
                    }), true, true)
                //parallel to parallel
                .pushThread(new Thread("parallel thread b")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("g", 6);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("h", 7);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("i", 8);
                        _timeout(r.scceeded, delay);//80
                    }), true, true)
                //parallel to serial
                .pushThread(new Thread("serial thread b")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("j", 9);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("k", 10);
                        _timeout(r.scceeded, delay);//160
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("l", 11);
                        _timeout(r.scceeded, delay);//240
                    }), false, true)
                //serial to serial
                .pushThread(new Thread("serial thread c")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("m", 12);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("n", 13);
                        _timeout(r.scceeded, delay);//160
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("o", 14);
                        _timeout(r.scceeded, delay);//240
                    }), false, true)
                .exec(_doAsyncTest);
        }
        
        [Test(async)]
        public function testExecHybrid():void
        {
            var delay:int = 80;
            
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_p.name, equalTo("TestExecHybrid"));
                    assertThat(_p.result, equalTo(Status.SCCEEDED));
                    assertThat(_p.phase, equalTo(Status.FINISHED));
                    assertThat(_p.progress, equalTo(1));
                    
                    var k:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i"];
                    for (var i:int = 0; i < k.length; i++) 
                        assertThat(_p.readData(k[i]), equalTo(i));
                }, _assertDelay);
            
            new Process("TestExecHybrid")
                .pushThread(new Thread("serial thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("a", 0);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("b", 1);
                        _timeout(r.scceeded, delay);//160
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("c", 2);
                        _timeout(r.scceeded, delay);//240
                    }), false, true)
                //async to sync
                .pushThread(new Thread("parallel thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("d", 3);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("e", 4);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("f", 5);
                        _timeout(r.scceeded, delay);//320
                    }), true, false)
                //sync to async
                .pushThread(new Thread("parallel thread b")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("g", 6);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("h", 7);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("i", 8);
                        _timeout(r.scceeded, delay);//320
                    }), true, true)
                .exec(_doAsyncTest);
        }
        
        [Test(async)]
        public function testTerminate():void
        {
            var delay:int = 80;
            
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_p.name, equalTo("TestTerminate"));
                    assertThat(_p.result, equalTo(Status.TERMINATE));
                    assertThat(_p.phase, equalTo(Status.FINISHED));
                    /*
                    var k:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i"];
                    for (var i:int = 0; i < k.length; i++) 
                        assertThat(_p.readData(k[i]), equalTo(i));
                    */
                }, _assertDelay);
            
            var p:Process = new Process("TestTerminate")
                .pushThread(new Thread("serial thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("a", 0);
                        _timeout(r.scceeded, delay);//80
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("b", 1);
                        _timeout(r.scceeded, delay);//160
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("c", 2);
                        _timeout(r.scceeded, delay);//240
                    }), false)
                .pushThread(new Thread("parallel thread a")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("d", 3);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("e", 4);
                        _timeout(r.scceeded, delay);//320
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("f", 5);
                        _timeout(r.scceeded, delay);//320
                    }), true)
                .pushThread(new Thread("parallel thread b")
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("g", 6);
                        _timeout(r.scceeded, delay);//400
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("h", 7);
                        _timeout(r.scceeded, delay);//400
                    })
                    .pushRoutine(function(r:Routine, t:Thread):void
                    {
                        r.writeData("i", 8);
                        _timeout(r.scceeded, delay);//400
                    }), true);
            
            p.exec(_doAsyncTest);
            var r:int = Math.random() * 350;
            Log.info("■■■ terminate -> ", r, "msec.");
            setTimeout(p.terminate, r);
        }
    }
}