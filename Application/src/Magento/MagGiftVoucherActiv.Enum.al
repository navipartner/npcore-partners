enum 6014434 "NPR Mag. Gift Voucher Activ."
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; OnPosting)
    {
        Caption = 'On Posting';
    }
    value(1; OnInsert)
    {
        Caption = 'On Insert';
    }
}
