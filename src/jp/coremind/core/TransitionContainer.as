package jp.coremind.core
{
    import jp.coremind.configure.ITransitionContainer;

    public class TransitionContainer implements ITransitionContainer
    {
        public static function restore():ITransitionContainer
        {
            return new RestoreTransition();
        }
        
        private var
            _name:String,
            _targetStage:String,
            _deleteRestoreHistory:Boolean,
            _length:int,
            _configure:Object;
        
        public function TransitionContainer(name:String = null, deleteRestoreHistory:Boolean = true, targetStage:String = TargetStage.STARLING)
        {
            _name = name;
            _length = 0;
            _targetStage = targetStage;
            _configure = {};
            _deleteRestoreHistory = deleteRestoreHistory;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function get length():int
        {
            return _length;
        }
        
        public function get targetStage():String
        {
            return _targetStage;
        }
        
        public function addTransition(layer:String, configure:Transition):TransitionContainer
        {
            if (!(layer in _configure)) _length++;
            _configure[layer] = configure;
            return this;
        }
        
        public function getTransition(layer:String):Transition
        {
            return layer in _configure ? _configure[layer]: null;
        }
        
        public function get deleteRestoreHistory():Boolean
        {
            return _deleteRestoreHistory;
        }
    }
}
import jp.coremind.configure.ITransitionContainer;
import jp.coremind.core.Application;
import jp.coremind.core.TargetStage;
import jp.coremind.core.Transition;

class RestoreTransition implements ITransitionContainer
{
    public function RestoreTransition()
    {
    }
    
    public function get name():String
    {
        return "RestoreTransition";
    }
    
    public function get length():int
    {
        return Application.configure.viewLayer.viewLength;
    }
    
    public function get targetStage():String
    {
        return TargetStage.STARLING;
    }
    
    public function getTransition(layer:String):Transition
    {
        return Transition.restore();
    }
    
    public function get deleteRestoreHistory():Boolean
    {
        return false;
    }
}