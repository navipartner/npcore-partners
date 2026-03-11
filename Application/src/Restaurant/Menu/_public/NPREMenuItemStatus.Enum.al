#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
enum 6014578 "NPR NPRE Menu Item Status"
{
    Access = Public;
    Extensible = false;
    Caption = 'Menu Item Status';

    value(0; Active)
    {
        Caption = 'Active';
    }
    value(1; "Inactive Visible")
    {
        Caption = 'Inactive (visible)';
    }
    value(2; "Inactive Hidden")
    {
        Caption = 'Inactive (hidden)';
    }
}
#endif
