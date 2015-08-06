package jp.coremind.utility.process
{
    import flash.utils.setTimeout;
    
    import mx.events.FlexEvent;
    
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;
    
    import org.flexunit.assertThat;
    import org.flexunit.async.Async;
    import org.hamcrest.object.equalTo;
    
    public class TestThread
    {		
        private static const _asyncDelay:int  = 100;
        private static const _assertDelay:int = 1000;
        
        private var _t:Thread;
        private var _asyncHandler:Function;
        
        [Before]
        public function setUp():void
        {
        }
        
        [After]
        public function tearDown():void
        {
            _t = null;
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
        
        private function _doAsyncTest(t:Thread):void
        {
            _t = t;
            _asyncHandler();
        }
        
        [Test]
        public function testPushRoutine():void
        {
            new Thread("TestPushRoutine")
                .pushRoutine(function(r:Routine, t:Thread):void {})
                .pushRoutine(function(r:Routine, t:Thread):void {}, [1, true, [59, 72], { sampleArguments:0 }]);
        }
        
        [Test(async)]
        public function TestReadDataAndWriteData0():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    //既に終了初期化されてから呼び出されてるのでこの評価はうまくいかない
                    assertThat(_t.progress, equalTo(1));
                    assertThat(_t.result, equalTo(Status.SCCEEDED));
                    assertThat(_t.phase, equalTo(Status.FINISHED));
                    
                    assertThat(_t.readData("key"), equalTo("res1 value"));
                }, _assertDelay);
            
            new Thread("TestReadDataAndWriteData 0")
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    setTimeout(function():void
                    {
                        r.writeData("key", "res1 value");
                        r.scceeded();
                    }, _asyncDelay);
                }).exec(_doAsyncTest);
        }
        
        [Test(async)]
        public function testReadDataAndWriteData1():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_t.progress, equalTo(1));
                    assertThat(_t.result, equalTo(Status.SCCEEDED));
                    assertThat(_t.phase, equalTo(Status.FINISHED));
                    
                    assertThat(_t.readData("key1"), equalTo("res1 value"));
                    assertThat(_t.readData("key2"), equalTo("res2 value"));
                }, _assertDelay);
            
            new Thread("TestReadDataAndWriteData 1")
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    setTimeout(function():void {
                        r.writeData("key1", "res1 value");
                        r.scceeded();
                    }, _asyncDelay * 1);
                })
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    //serialの場合このRoutine以前の結果は取得できる
                    assertThat(t.readData("key1"), equalTo("res1 value"));
                    //progressは「完了済みRoutine / 全Routine」として取得できる
                    assertThat(t.progress, equalTo(.5));
                    
                    r.writeData("key2", "res2 value");
                    
                    setTimeout(function():void { r.scceeded(); }, _asyncDelay * 1);
                }).exec(_doAsyncTest);
        }
        
        [Test(async)]
        public function testReadDataAndWriteData2():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_t.progress, equalTo(1));
                    assertThat(_t.result, equalTo(Status.SCCEEDED));
                    assertThat(_t.phase, equalTo(Status.FINISHED));
                    
                    assertThat(_t.readData("key1"), equalTo("res1 value"));
                    assertThat(_t.readData("key2"), equalTo("res2 value"));
                }, _assertDelay);
            
            new Thread("TestReadDataAndWriteData 2")
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    setTimeout(function():void {
                        r.writeData("key1", "res1 value");
                        r.scceeded();
                    }, _asyncDelay * 5 * Math.random());
                })
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    //pallarelの場合callbackが呼ばれるまで他のRoutineの結果は取得できない
                    setTimeout(function():void {
                        r.writeData("key2", "res2 value");
                        r.scceeded();
                    }, _asyncDelay * 5 * Math.random());
                }).exec(_doAsyncTest, true);//Pallarel = true
        }
        
        [Test(async)]
        public function testResetStatus():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    _t.resetStatus();
                    
                    assertThat(_t.progress, equalTo(0));
                    assertThat(_t.result, equalTo(Status.IDLING));
                    assertThat(_t.phase, equalTo(Status.IDLING));
                    
                    assertThat(_t.readData("key1"), equalTo(undefined));
                }, _assertDelay);
            
            var u:Thread = new Thread("TestResetStatus");
            u.pushRoutine(function(r:Routine, t:Thread):void
            {
                setTimeout(function():void {
                    r.writeData("key1", "res1 value");
                    r.scceeded();
                }, _asyncDelay);
            }).exec(_doAsyncTest);
            
            //起動中の場合、resetStatusは呼び出しても実行されない
            u.resetStatus();
        }
        
        [Test(async)]
        public function testTerminatePallarel():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_t.progress, equalTo(1));
                    assertThat(_t.result, equalTo(Status.TERMINATE));
                    assertThat(_t.phase, equalTo(Status.FINISHED));
                    
                    assertThat(_t.readData("key1"), equalTo("res1 value"));//terminate前の呼び出しなので値は入ってる
                    assertThat(_t.readData("key2"), equalTo(undefined));//terminate後の呼び出しなので値は入っていない
                }, _assertDelay);
            
            var u:Thread = new Thread("TestTerminatePallarel")
            //terminateが呼ばれる前に呼び出される
            u.pushRoutine(function(r:Routine, t:Thread):void
            {
                setTimeout(function():void
                {
                    assertThat(t.result, equalTo(Status.IDLING));
                    assertThat(t.phase, equalTo(Status.RUNNING));
                    
                    r.writeData("key1", "res1 value");
                    r.scceeded();
                }, 50);
            })
            //terminateが呼ばれた時に既に稼動しているので呼び出し自体はある
            .pushRoutine(function(r:Routine, t:Thread):void
            {
                setTimeout(function():void
                {
                    //但し、terminateされてリセットされている
                    assertThat(t.result, equalTo(Status.IDLING));
                    assertThat(t.phase, equalTo(Status.IDLING));
                    
                    //↓も無視される
                    r.writeData("key2", "res2 value");
                    r.scceeded();
                }, _asyncDelay * 5 * Math.random() + 100);
            }).exec(_doAsyncTest, true);
            
            //起動中のステータスチェック
            assertThat(u.result, equalTo(Status.IDLING));
            assertThat(u.phase, equalTo(Status.RUNNING));
            
            //強制終了
            setTimeout(u.terminate, 80);
        }
        
        [Test(async)]
        public function testTerminateSerial():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(int(_t.progress * 100), equalTo(66));//実質二つのRoutineしか実行されなかったので66%
                    assertThat(_t.result, equalTo(Status.TERMINATE));
                    assertThat(_t.phase, equalTo(Status.FINISHED));
                    
                    assertThat(_t.readData("key1"), equalTo("res1 value"));//terminate前の呼び出しなので値は入ってる
                    assertThat(_t.readData("key2"), equalTo(undefined));//terminate後の呼び出しなので値は入っていない
                    assertThat(_t.readData("key3"), equalTo(undefined));//terminate後の呼び出しなので値は入っていない
                }, _assertDelay);
            
            var u:Thread = new Thread("TestTerminateSerial")
                //terminateが呼ばれる前に呼び出される
                u.pushRoutine(function(r:Routine, t:Thread):void
                {
                    setTimeout(function():void
                    {
                        assertThat(t.result, equalTo(Status.IDLING));
                        assertThat(t.phase, equalTo(Status.RUNNING));
                        
                        r.writeData("key1", "res1 value");
                        r.scceeded();
                    }, 50);
                })
                //terminateが呼ばれた時に既に稼動しているので呼び出し自体はある
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    setTimeout(function():void
                    {
                        //但し、terminateされてリセットされている
                        assertThat(t.result, equalTo(Status.IDLING));
                        assertThat(t.phase, equalTo(Status.IDLING));
                        
                        //↓も無視される
                        r.writeData("key1", "res1 value");
                        r.scceeded();
                    }, _asyncDelay * 5 * Math.random() + 100);
                })
                //terminateが呼ばれた後に実行しようとするのでこの呼び出しはキャンセルされる
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    Log.info("terminateが呼ばれた後に実行しようとするのでこの呼び出しは実行しませんよ？");
                    r.writeData("key3", "res3 value");
                    r.scceeded();
                }).exec(_doAsyncTest);
            
            //強制終了
            setTimeout(u.terminate, 80);
        }
        
        [Test(async)]
        public function testUnbindRoutine():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    _t.unbindRoutine();
                    
                    assertThat(_t.progress, equalTo(0));
                    assertThat(_t.result, equalTo(Status.IDLING));
                    assertThat(_t.phase, equalTo(Status.IDLING));
                    
                    assertThat(_t.readData("key1"), equalTo(undefined));//terminate後の呼び出しなので値は入っていない
                }, _assertDelay);
            
            var u:Thread = new Thread("TestUnbindRoutine");
            u.pushRoutine(function(r:Routine, t:Thread):void
            {
                setTimeout(function():void {
                    r.writeData("key1", "res1 value");
                    r.scceeded();
                }, _asyncDelay);
            }).exec(_doAsyncTest);
            
            //起動中の場合、unbindRoutineは呼び出しても実行されない
            u.unbindRoutine();
        }
    }
}