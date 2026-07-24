enum 6059776 "NPR License Module"
{
    Access = Internal;
    Extensible = false;
    Caption = 'NPR License Module';

    value(0; _)
    {
        Caption = '', Locked = true;
    }
    value(1; POS)
    {
        Caption = 'POS', Locked = true;
    }
    value(2; KDS)
    {
        Caption = 'KDS', Locked = true;
    }
    value(3; Scanner)
    {
        Caption = 'Scanner', Locked = true;
    }
}
