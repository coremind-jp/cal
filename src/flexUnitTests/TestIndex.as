package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import jp.coremind.utility.data.Index;
    
    public class TestIndex
    {		
        private var index:Index;
        [Before]
        public function setUp():void
        {
            index = new Index();
            index.refreshLength(5);
        }
        
        [After]
        public function tearDown():void
        {
            index = null;
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
        public function testGet_head():void
        {
            Assert.assertEquals(0, index.head);
            index.next();
            Assert.assertEquals(1, index.head);
        }
        
        [Test]
        public function testIsFirst():void
        {
            Assert.assertEquals(true, index.isFirst());
            
            Assert.assertEquals(true, index.next());
            
            Assert.assertEquals(false, index.isFirst());
        }
        
        [Test]
        public function testIsLast():void
        {
            Assert.assertEquals(false, index.isLast());
            
            Assert.assertEquals(true, index.next());
            Assert.assertEquals(true, index.next());
            Assert.assertEquals(true, index.next());
            Assert.assertEquals(true, index.next());
            
            Assert.assertEquals(true, index.isLast());
        }
        
        [Test]
        public function testJump():void
        {
            //範囲外の値を指定した場合丸め込まれる
            index.jump(5);
            Assert.assertEquals(4, index.head);
            
            index.jump(-6);
            Assert.assertEquals(0, index.head);
            
            //設定した長さ以内であればジャンプできる
            index.jump(2);
            Assert.assertEquals(2, index.head);
            
            index.jump(1);
            Assert.assertEquals(1, index.head);

            index.jump(4);
            Assert.assertEquals(4, index.head);
        }
        
        [Test]
        public function testGet_length():void
        {
            Assert.assertEquals(5, index.length);
        }
        
        [Test]
        public function testNext():void
        {
            var counter:int = 0;
            
            do { Assert.assertEquals(counter++, index.head); }
            while (index.next())
        }
        
        [Test]
        public function testPrev():void
        {
            var counter:int = 4;
            index.jump(index.length-1);
            
            do { Assert.assertEquals(counter--, index.head); }
            while (index.prev())
        }
        
        [Test]
        public function testRefreshLength():void
        {
            Assert.assertEquals(5, index.length);
            index.jump(4);
            Assert.assertEquals(4, index.head);
            
            //設定した長さはrefreshLengthで変えられる
            index.refreshLength(2);
            Assert.assertEquals(2, index.length);
            
            //その場合、変える前ヘッド位置が新しい長さを超えていたら範囲内に丸め込まれる
            Assert.assertEquals(1, index.head);
            
            //逆の場合、ヘッドは変わらず長さのみ更新される
            index.refreshLength(10);
            Assert.assertEquals(10, index.length);
            Assert.assertEquals( 1, index.head);
        }
    }
}