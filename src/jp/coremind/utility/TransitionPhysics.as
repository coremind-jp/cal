package jp.coremind.utility
{
    import flash.display.DisplayObject;

    public class TransitionPhysics
    {
        public function TransitionPhysics(t:DisplayObject, inputSpeed:Number, maxSpeed:Number)
        {
            if (maxSpeed < inputSpeed)
                inputSpeed = maxSpeed;
            
            $.loop.framePreProcess.setInterval(function():void
            {
                t.x += inputSpeed;
                inputSpeed
            })
        }
    }
}