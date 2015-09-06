package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import jp.coremind.model.StatusModel;
    import jp.coremind.utility.data.Status;
    
    import org.flexunit.assertThat;
    import org.hamcrest.object.equalTo;
    
    public class TestMultistageStatus
    {		
        private var _stats:StatusModel;
        
        [Before]
        public function setUp():void
        {
            _stats = new StatusModel();
        }
        
        [After]
        public function tearDown():void
        {
            _stats.destroy();
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
        public function testEqual():void
        {/*
            //初期追加
            _stats.createGroup("test10" ,  10, ["test10decrement"]);
            _stats.createGroup("test100", 100, ["test100decrement"]);
            _stats.createGroup("test50" ,  50, ["test50decrement"]);
            
            assertThat(_stats.equal(Status.IDLING), equalTo(true));
            assertThat(_stats.headGroup, equalTo("test10"));
            
            //既存のpriorityよりも高いpriorityグループのステータスを設定したらそのグループがアクティブになる
            _stats.update("test100", "init100");
            
            assertThat(_stats.equal("init100"), equalTo(true));
            assertThat(_stats.headGroup, equalTo("test100"));
            
            //現在アクティブになっているステータスが保持するpriorityよりも低いpriorityグループのステータスを設定してもそのグループはアクティブにならない
            //ただし、ステータスの更新自体は行われている(この場合test10のステータスはinit10になっている)
            //(ignorepriorityがtrue時のみ)
            _stats.update("test10", "init10");
            
            assertThat(_stats.equal("init100"), equalTo(true));
            assertThat(_stats.headGroup, equalTo("test100"));
            
            //createGroupの第三引数に与えたステータスにマッチした値がupdateで設定された場合、
            //一つしたのグループがアクティブになる
            var v:Vector.<String> = _stats.update("test100", "test100decrement");
            
            assertThat(_stats.headGroup, equalTo("test50"));
            assertThat(_stats.equal(Status.IDLING), equalTo(true));
            assertThat(v.length, equalTo(2));
            assertThat(v[0], equalTo("test100"));
            assertThat(v[1], equalTo("test50"));
            
            _stats.update("test50", "test50decrement");
            
            assertThat(_stats.headGroup, equalTo("test10"));
            //assertThat(_stats.equal("init10"), equalTo(true));//Status.IDLINGではなく、67行目で更新したinit10になっていることを確認
            assertThat(_stats.equal("idling"), equalTo(true));//Status.IDLINGではなく、67行目で更新したinit10になっていることを確認
            
            //仮に一番下のグループのステータスにdecrementStatusが設定されていてもグループに変化は起きない
            _stats.update("test10", "test10decrement");
            
            assertThat(_stats.headGroup, equalTo("test10"));
            assertThat(_stats.equal("test10decrement"), equalTo(true));//※ステータスはinit10からtest10decrementに変わっている
            
            _stats.update("test50", "move50");
            assertThat(_stats.headGroup, equalTo("test50"));
            assertThat(_stats.equal("move50"), equalTo(true));
            
            _stats.createGroup("test200", 200, []);*/
        }
    }
}