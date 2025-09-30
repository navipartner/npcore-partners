enum 6014690 "NPR DE Export State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Caption = 'DE Export State';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; CANCELLED)
    {
        Caption = 'Cancelled';
    }
    value(2; PENDING)
    {
        Caption = 'Pending';
    }
    value(3; WORKING)
    {
        Caption = 'Working';
    }
    value(4; COMPLETED)
    {
        Caption = 'Completed';
    }
    value(5; ERROR)
    {
        Caption = 'Error';
    }
}