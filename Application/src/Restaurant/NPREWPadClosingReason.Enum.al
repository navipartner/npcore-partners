enum 6014483 "NPR NPRE W/Pad Closing Reason"
{
    Caption = 'Waiter Pad Closing Reason';
    Extensible = true;

    value(0; Undefined)
    {
        Caption = 'Undefined';
    }
    value(1; "Manually Closed")
    {
        Caption = 'Manually Closed';
    }
    value(2; "Finished Sale")
    {
        Caption = 'Finished Sale';
    }
    value(3; "Cancelled Sale")
    {
        Caption = 'Cancelled Sale';
    }
    value(4; "Split/Merge Waiter Pad")
    {
        Caption = 'Split/Merge Waiter Pad';
    }
}