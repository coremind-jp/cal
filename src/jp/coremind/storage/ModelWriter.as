package jp.coremind.storage
{
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.model.transaction.Diff;
    import jp.coremind.model.transaction.HashTransaction;
    import jp.coremind.model.transaction.ListTransaction;
    import jp.coremind.model.transaction.Transaction;
    import jp.coremind.utility.Log;

    public class ModelWriter extends StorageAccessor
    {
        public static const TAG:String = "[ModelWriter]";
        Log.addCustomTag(TAG);
        
        private var
            _reader:ModelReader,
            _transaction:Transaction;
        
        public function ModelWriter(id:String, type:String = StorageType.HASH)
        {
            _reader = storage.requestReader(id, type);
        }
        
        public function destroy():void
        {
            _reader = null;
            
            if (_transaction)
            {
                _transaction.rollback();
                _transaction = null;
            }
        }
        
        public function get id():String   { return _reader.id; }
        public function get type():String { return _reader.type; }
        public function read():*          { return _reader.read(); }
        
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
            Log.custom(TAG, "preview");
            if (_transaction) _reader.dispatchByPreview(_transaction.apply(_reader.read()));
        }
        
        public function commit():void
        {
            Log.custom(TAG, "commit");
            
            if (_transaction) 
            {
                var diff:Diff = _transaction.apply(_reader.read());
                
                storage.update(this, diff.editedOrigin);
                
                _reader.dispatchByCommit(diff);
            }
            
            _transaction.rollback();
            _transaction = null;
        }
    }
}