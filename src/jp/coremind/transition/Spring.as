package jp.coremind.transition
{
    public class Spring
    {
        public var coefficient:Number;

        public function Spring(coefficient:Number = 0)
        {
            this.coefficient = coefficient;
        }
        
        public function calcElasticForce(stretch:Number):Number
        {
            return stretch * coefficient;
        }
    }
}