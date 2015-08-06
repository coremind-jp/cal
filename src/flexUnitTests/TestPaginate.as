package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import jp.coremind.utility.data.Paginate;
    
    public class TestPaginate
    {		
        private var _source:Array;
        private var _list:Paginate;
        
        [Before]
        public function setUp():void
        {
            _list = new Paginate(_source = [
                 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
                10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
                20, 21, 22, 23, 24, 25, 26, 27
            ], 10);
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
            Assert.assertEquals(3, _list.length);
            _list.destory();
            Assert.assertEquals(0, _list.length);
        }
        
        [Test]
        public function testGetElement():void
        {
            var r:Array;
            
            r = _list.getElementList();
            Assert.assertEquals(10, r.length);
            new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9).
                forEach(function(v:*, i:int, arr:Array):Boolean {
                    Assert.assertTrue(true, r.indexOf(v) > -1);
                });
            
            //末尾でnextを実行しても取得できる要素は末尾のデータ
            Assert.assertEquals(true, _list.next());
            r = _list.getElementList();
            Assert.assertEquals(10, r.length);
            new Array(10, 11, 12, 13, 14, 15, 16, 17, 18, 19).
                forEach(function(v:*, i:int, arr:Array):Boolean {
                    Assert.assertTrue(true, r.indexOf(v) > -1);
                });
            
            Assert.assertEquals(true, _list.next());
            r = _list.getElementList();
            Assert.assertEquals(8, r.length);
            new Array(20, 21, 22, 23, 24, 25, 26, 27).
                forEach(function(v:*, i:int, arr:Array):Boolean {
                    Assert.assertTrue(true, r.indexOf(v) > -1);
                });
            
            //末尾でnextを実行しても取得できる要素は末尾のデータ
            Assert.assertEquals(false, _list.next());
            r = _list.getElementList();
            Assert.assertEquals(8, r.length);
            new Array(20, 21, 22, 23, 24, 25, 26, 27).
                forEach(function(v:*, i:int, arr:Array):Boolean {
                    Assert.assertTrue(true, r.indexOf(v) > -1);
                });
            
            //但し、linkedをtrueにすると末尾と先頭が結合されて循環参照になる
            _list.linked = true;
           
            Assert.assertEquals(true, _list.next());
            r = _list.getElementList();
            Assert.assertEquals(10, r.length);
            new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9).
                forEach(function(v:*, i:int, arr:Array):Boolean {
                    Assert.assertTrue(true, r.indexOf(v) > -1);
                });
            
            //prevメソッドについても同様
            Assert.assertEquals(true, _list.prev());
            r = _list.getElementList();
            Assert.assertEquals(8, r.length);
            new Array(20, 21, 22, 23, 24, 25, 26, 27).
                forEach(function(v:*, i:int, arr:Array):Boolean {
                    Assert.assertTrue(true, r.indexOf(v) > -1);
                });
        }
        
        [Test]
        public function testGet_length():void
        {
            Assert.assertEquals(3, _list.length);
            
            //配列長を変更させるとListインスタンスの長さにも反映される.
            _source.splice(0, 20);
            
            Assert.assertEquals(1, _list.length);
        }
        
        [Test]
        public function testRefreshLength():void
        {
            _list.jump(2);
            Assert.assertEquals(2, _list.head);
            Assert.assertEquals(3, _list.length);
            
            //要素数の更新後にヘッド位置は自動で更新されない
            _source.splice(0, 17);//(ex ヘッドが末尾状態で要素を減らす
            Assert.assertEquals(2, _list.head);//ヘッドは削除前の位置のままになっている(3はspliceによって既に存在していない)
            Assert.assertEquals(2, _list.length);
            
            //ヘッドの位置は明示的にこrefreshLengthを呼ばなければ更新されないので注意
            _list.refreshLength();
            
            Assert.assertEquals(1, _list.head);//ヘッドが末尾以上の位置だった場合, refreshLengthによって丸め込まれる
            Assert.assertEquals(2, _list.length);
        }
    }
}