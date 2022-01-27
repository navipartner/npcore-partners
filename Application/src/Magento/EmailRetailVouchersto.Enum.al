enum 6014437 "NPR E-mail Retail Vouchers to"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Bill-to Customer")
    {
        Caption = 'Bill-to Customer';
    }
}
