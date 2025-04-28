enum 6059863 "NPR HU L Return Reason Code"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; "V1")
    {
        Caption = 'Faulty goods';
    }
    value(2; "V2")
    {
        Caption = 'Customer cancels the purchase (return)';
    }
    value(3; "V3")
    {
        Caption = 'Other';
    }
    value(4; "S1")
    {
        Caption = 'Customer cancels the purchase (void)';
    }
    value(5; "S2")
    {
        Caption = 'Cashier: incorrect entry';
    }
    value(6; "S3")
    {
        Caption = 'Cashier: incorrect currency entered';
    }
    value(7; "S4")
    {
        Caption = 'Cashier: item out of stock';
    }
    value(8; "S5")
    {
        Caption = 'Technical: incorrect document issued';
    }
    value(9; "S6")
    {
        Caption = 'Technical: unsuccessful currency usage';
    }
    value(10; "S7")
    {
        Caption = 'Technical: incorrect customer data/incorrect entry';
    }
    value(11; "S8")
    {
        Caption = 'Technical: mystery shopping';
    }
    value(12; "S0")
    {
        Caption = 'Other';
    }
}