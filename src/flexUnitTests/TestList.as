package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import jp.coremind.data.List;
    
    public class TestList
    {		
        private var _source:Array;
        private var _list:List;
        
        [Before]
        public function setUp():void
        {
            _list = new List(_source = ["tokyo", "kyoto", "nagoya", "osaka", "hokkaido"]);
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
        public function testDestory():void
        {
            Assert.assertEquals(5, _list.length);
            _list.destory();
            Assert.assertEquals(0, _list.length);
        }
        
        [Test]
        public function testGetElement():void
        {
            Assert.assertEquals("tokyo", _list.headElement);
            _list.next();
            Assert.assertEquals("kyoto", _list.headElement);
            _list.next();
            Assert.assertEquals("nagoya", _list.headElement);
            _list.next();
            Assert.assertEquals("osaka", _list.headElement);
            _list.next();
            Assert.assertEquals("hokkaido", _list.headElement);
            
            //末尾でnextを実行しても取得できる要素は末尾のデータ
            Assert.assertEquals(false, _list.next());
            Assert.assertEquals("hokkaido", _list.headElement);
            
            //但し、linkedをtrueにすると末尾と先頭が結合されて循環参照になる
            _list.linked = true;
            Assert.assertEquals(true, _list.next());
            Assert.assertEquals("tokyo", _list.headElement);
            
            //prevメソッドについても同様
            Assert.assertEquals(true, _list.prev());
            Assert.assertEquals("hokkaido", _list.headElement);
        }
        
        [Test]
        public function testGet_length():void
        {
            Assert.assertEquals(5, _list.length);
            
            //配列長を変更させるとListインスタンスの長さにも反映される.
            _source.splice(2, 1);
            
            Assert.assertEquals(4, _list.length);
        }
        
        [Test]
        public function testRefreshLength():void
        {
            _list.jump(4);
            Assert.assertEquals(4, _list.head);
            Assert.assertEquals(5, _list.length);
            
            //要素数の更新後にヘッド位置は自動で更新されない
            _source.splice(2, 1);//(ex ヘッドが末尾状態で要素を減らす
            Assert.assertEquals(4, _list.head);//ヘッドは削除前の位置のままになっている(3はspliceによって既に存在していない)
            Assert.assertEquals(4, _list.length);
            
            //ヘッドの位置は明示的にこrefreshLengthを呼ばなければ更新されないので注意
            _list.refreshLength();
            
            Assert.assertEquals(3, _list.head);//ヘッドが末尾以上の位置だった場合, refreshLengthによって丸め込まれる
            Assert.assertEquals(4, _list.length);
        }
    }
}