enum 6059779 "NPR ES Inv. Registration State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; PENDING)
    {
        Caption = 'Pending';
    }
    value(2; REGISTERED)
    {
        Caption = 'Registered';
    }
    value(3; REQUIRES_CORRECTION)
    {
        Caption = 'Requires correction';
    }
    value(4; REQUIRES_INSPECTION)
    {
        Caption = 'Requires inspection';
    }
    value(5; STORED)
    {
        Caption = 'Stored';
    }
    value(6; INVALID)
    {
        Caption = 'Invalid';
    }
}
