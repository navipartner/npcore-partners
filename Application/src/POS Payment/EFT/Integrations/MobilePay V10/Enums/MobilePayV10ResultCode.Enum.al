enum 6014469 "NPR MobilePayV10 Result Code"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; Prepared)
    {
    }
    value(1; Initiated)
    {
    }
    value(2; Paired)
    {
    }
    value(3; IssuedTouser)
    {
    }
    value(4; Reserved)
    {
    }
    value(5; CancelledByUser)
    {
    }
    value(6; CancelledByClient)
    {
    }
    value(7; CancelledByMobilePay)
    {
    }
    value(8; ExpiredAndCancelled)
    {
    }
    value(9; Captured)
    {
    }
    value(10; RejectedByMobilePayDueToAgeRestrictions)
    {
    }

}
