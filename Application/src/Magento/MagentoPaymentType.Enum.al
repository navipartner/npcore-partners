enum 6014425 "NPR Magento Payment Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(5; Voucher)
    {
        Caption = 'Voucher';
    }
    value(6; "Payment Method")
    {
        Caption = 'Payment Method';
    }
}
