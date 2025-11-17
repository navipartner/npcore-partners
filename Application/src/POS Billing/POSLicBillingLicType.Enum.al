#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059949 "NPR POS Lic. Billing Lic. Type"
{
    Access = Internal;
    Extensible = false;
    Caption = 'POS License Billing License Type';

    value(0; _)
    {
        Caption = '';
    }
    value(3; months03)
    {
        Caption = '3 Months';
    }
    value(12; months12)
    {
        Caption = '1 Year';
    }
}
#endif