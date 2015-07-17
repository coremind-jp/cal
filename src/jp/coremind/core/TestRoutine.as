package jp.coremind.core
{
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.setTimeout;
    
    import mx.events.FlexEvent;
    
    import jp.coremind.utility.Log;
    import jp.coremind.utility.Status;
    
    import org.flexunit.assertThat;
    import org.flexunit.async.Async;
    import org.hamcrest.object.equalTo;
    
    /**
     * tryItで実行するクロージャ関数仕様
     * function(r:Routine, t:Thread):void
     * {
     *      //この中で以下の3つのいずれかを呼ぶ
     *      r.scceeded();
     *      r.failed();
     *      r.fatal();
     * 
     *      //t（Thread）はこのRoutineの親となっているスレッドオブジェクト
     *      //このオブジェクトからそれ以前に実行されたRoutineの戻り値などが取得できる
     * }
     * 
     * tryItで実行されたクロージャ関数に対するコンプリートハンドラ仕様
     * function(r:Routine):void
     * {
     *      p.resultContexにはscceeded, failed, fatalメソッドに渡した引数が入っている
     *      p.resetStatus();　このメソッドでRoutineが保持する全ての変数が初期化される(参照も切られる)
     * }
     */
    public class TestRoutine
    {	
        private static const _asyncDelay:int  = 100;
        private static const _assertDelay:int = 200;
        
        private var _r:Routine;
        private var _mem:Object;
        private var _asyncHandler:Function;
        private var _terminated:Boolean;
        
        [Before]
        public function setUp():void
        {
            _mem = {};
            _terminated = false;
        }
        
        [After]
        public function tearDown():void
        {
            _r = null;
            _mem = null;
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
        
        private function _doAsyncTest(r:Routine):void
        {
            _r = r;
            _asyncHandler();
        }
        
        [Test(async)]
        public function testFailed():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_r.progress.rate, equalTo(1));
                    assertThat(_r.result.value, equalTo(Status.FAILED));
                    assertThat(_r.phase.value, equalTo(Status.FINISHED));
                    assertThat(_mem.key, equalTo("failed result."));
                }, _assertDelay);
            
            new Routine("FailedTest").exec(
                function(r:Routine):void
                {
                    assertThat(r.progress.rate, equalTo(0));
                    
                    setTimeout(function():void {
                        r.writeData("key", "failed result.");
                        r.failed("failed message.");
                    }, _asyncDelay);
                }, _mem, _doAsyncTest);
        }
        
        [Test(async)]
        public function testFatal():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_r.progress.rate, equalTo(1));
                    assertThat(_r.result.value, equalTo(Status.FATAL));
                    assertThat(_r.phase.value, equalTo(Status.FINISHED));
                    assertThat(_mem.key, equalTo("fatal result."));
                }, _assertDelay);
                
            new Routine("FatalTest").exec(
                function(r:Routine):void
                {
                    assertThat(r.progress.rate, equalTo(0));
                    
                    setTimeout(function():void {
                        r.writeData("key", "fatal result.");
                        r.fatal("fatal message.");
                    }, _asyncDelay);
                }, _mem, _doAsyncTest);
        }
        
        [Test(async)]
        public function testScceeded():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_r.progress.rate, equalTo(1));
                    assertThat(_r.result.value, equalTo(Status.SCCEEDED));
                    assertThat(_r.phase.value, equalTo(Status.FINISHED));
                    assertThat(_mem.key, equalTo("scceeded result."));
                    
                    //リセット後のステータスチェック
                    _r.resetStatus();
                    assertThat(_r.progress.rate, equalTo(0));
                    assertThat(_r.result.value, equalTo(Status.IDLING));
                    assertThat(_r.phase.value, equalTo(Status.IDLING));
                    
                }, _assertDelay);
            
            new Routine("ScceededTest").exec(
                function(r:Routine):void
                {
                    assertThat(r.progress.rate, equalTo(0));
                    
                    setTimeout(function():void {
                        r.writeData("key", "scceeded result.");
                        r.scceeded("scceeded message.");
                    }, _asyncDelay);
                }, _mem, _doAsyncTest);
        }
        
        [Test(async)]
        public function testResetStatus():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    _r.resetStatus();
                    assertThat(_r.progress.rate, equalTo(0));
                    assertThat(_r.result.value, equalTo(Status.IDLING));
                    assertThat(_r.phase.value, equalTo(Status.IDLING));
                }, _assertDelay);
            
            new Routine("ResetStatus").exec(
                function(r:Routine):void
                {
                    setTimeout(function():void {
                        r.scceeded("scceeded message.");
                    }, _asyncDelay);
                },
                _mem, _doAsyncTest);
        }
        
        [Test(async)]
        public function testTerminate():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_r.progress.rate, equalTo(1));
                    assertThat(_r.result.value, equalTo(Status.TERMINATE));
                    assertThat(_r.phase.value, equalTo(Status.FINISHED));
                    assertThat(_terminated, equalTo(true));
                    _r.dumpStatus();
                }, _assertDelay);
            
            var q:Routine = new Routine("TerminateTest");
            q.exec(function(r:Routine):void
            {
                //起動中のステータスチェック
                assertThat(r.result.value, equalTo(Status.IDLING));
                assertThat(r.phase.value, equalTo(Status.RUNNING));
                
                //外部からterminateが呼ばれた際にこのprocessを中断させる処理を追加できる
                //追加しない場合、process自体は最後まで処理される
                r.terminateHandler = function():void
                {
                    _terminated = true;
                    Log.info("called terminate.");
                };
                
                //terminateが呼ばれるのでこれは実行されない
                setTimeout(function():void {
                    r.writeData("key", "scceeded result.");
                    r.scceeded("scceeded message.");
                }, _asyncDelay);
            }, _mem, _doAsyncTest);
            
            //起動中のステータスチェック
            assertThat(q.result.value, equalTo(Status.IDLING));
            assertThat(q.phase.value, equalTo(Status.RUNNING));
            
            //強制終了
            setTimeout(q.terminate, _asyncDelay / 2);
        }
        
        [Test(async)]
        public function testUpdateProgress():void
        {
            _asyncHandler = Async.asyncHandler(
                this,
                function(e:FlexEvent, ctx:Object):void
                {
                    assertThat(_r.progress.rate, equalTo(1));
                    assertThat(_r.result.value, equalTo(Status.SCCEEDED));
                    assertThat(_r.phase.value, equalTo(Status.FINISHED));
                    assertThat(_mem.dlc is URLLoader, equalTo(true));
                }, 5000);
            
            var q:Routine = new Routine("LoadTest");
            q.exec(function(r:Routine):void
            {
                var l:URLLoader = new URLLoader(new URLRequest("http://www.anohana.jp/img/right_area/01_top/keyvisual.jpg"));
                l.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void
                {
                    r.updateProgress(0, e.bytesTotal, e.bytesLoaded);
                    Log.info(r.progress.rate);
                });
                l.addEventListener(Event.COMPLETE, function(e:Event):void
                {
                    r.writeData("dlc", e.currentTarget);
                    r.scceeded("load complete.");
                });
            }, _mem, _doAsyncTest);
        }
    }
}