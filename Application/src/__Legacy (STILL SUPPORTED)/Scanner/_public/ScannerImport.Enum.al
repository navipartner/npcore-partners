enum 6014488 "NPR Scanner Import" implements "NPR IScanner Import"
{
    Extensible = true;
    value(0; SALES)
    {
        Caption = 'SALES', Locked = true, MaxLength = 20;
        Implementation = "NPR IScanner Import" = "NPR Sales Scanner Import";
    }
    value(1; PURCHASE)
    {
        Caption = 'PURCHASE', Locked = true, MaxLength = 20;
        Implementation = "NPR IScanner Import" = "NPR Purchase Scanner Import";
    }
    value(2; TRANSFER)
    {
        Caption = 'TRANSFER', Locked = true, MaxLength = 20;
        Implementation = "NPR IScanner Import" = "NPR Transfer Scanner Import";
    }
}