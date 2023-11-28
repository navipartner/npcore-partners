enum 6014597 "NPR BG SIS VAT Category"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "A Category")
    {
        Caption = 'A Category (0%)';
    }
    value(1; "B Category")
    {
        Caption = 'B Category (20%)';
    }
    value(2; "C Category")
    {
        Caption = 'C Category (20%)';
    }
    value(3; "D Category")
    {
        Caption = 'D Category (9%)';
    }
    value(99; " ")
    {
        Caption = ' ';
    }
}
