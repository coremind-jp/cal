package jp.coremind.storage
{
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.storage.transaction.Diff;
    import jp.coremind.storage.transaction.HashTransaction;
    import jp.coremind.storage.transaction.ListTransaction;
    import jp.coremind.storage.transaction.Transaction;
    import jp.coremind.utility.Log;

    public class ModelWriter extends StorageAccessor
    {
        public static const TAG:String = "[ModelWriter]";
        Log.addCustomTag(TAG);
        
        private var
            _reader:ModelReader,
            _latestDiff:Diff,
            _transaction:Transaction;
        
        public function ModelWriter(id:String, type:String = StorageType.HASH)
        {
            _reader = storage.requestReader(id, type);
        }
        
        public function destroy():void
        {
            _deleteTransactionResult();
            _reader = null;
        }
        
        //ModelReader alias
        public function get id():String           { return _reader.id; }
        public function get type():String         { return _reader.type; }
        public function read():*                  { return _reader.read(); }
        //ModelReader alias
        
        public function requestTransactionByList():ListTransaction
        {
            if (!_transaction)
            {
                _reader.read() is Array ? _transaction = new ListTransaction():
                    Log.error("requestTransactionByList failed.", _reader.id, "is not Array");
            }
            
            return _transaction as ListTransaction;
        }
        
        public function requestTransactionByHash():HashTransaction
        {
            if (!_transaction)
            {
                $.isHash(_reader.read()) ? _transaction = new HashTransaction():
                    Log.error("requestTransactionByHash failed.", _reader.id, "is not Hash");
            }
            
            return _transaction as HashTransaction;
        }
        
        public function preview():void
        {
            if (_transaction)
            {
                Log.custom(TAG, "preview");
                
                _updateTransactionResult();
                
                _reader.dispatchByPreview(_latestDiff);
            }
        }
        
        public function commit(regenerateDiff:Boolean = false):void
        {
            if (_transaction) 
            {
                Log.custom(TAG, "commit");
                
                if (_latestDiff === null || regenerateDiff)
                    _updateTransactionResult();
                
                storage.update(this, _reader.readTransactionResult());
                
                var diff:Diff = _latestDiff;
                
                _deleteTransactionResult();
                
                _reader.dispatchByCommit(diff);
            }
        }
        
        private function _updateTransactionResult():void
        {
            _latestDiff = _transaction.apply(_reader.read());
            storage.writeTransactionResult(_reader.id, _latestDiff.deleteTransactionResult());
        }
        
        private function _deleteTransactionResult():void
        {
            if (_transaction)
                _transaction.rollback();
            
            _transaction = null;
            _latestDiff  = null;
            storage.deleteTransactionResult(_reader.id);
        }
    }
}