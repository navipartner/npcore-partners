enum 6059857 "NPR HU L VAT Index"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(1; "VAT Category A")
    {
        Caption = 'VAT Category A (5%)';
    }
    value(2; "VAT Category B")
    {
        Caption = 'VAT Category B (18%)';
    }
    value(3; "VAT Category C")
    {
        Caption = 'VAT Category C (27%)';
    }
    value(4; "VAT Category D")
    {
        Caption = 'VAT Category D (0% - AJT)';
    }
    value(5; "VAT Category E")
    {
        Caption = 'VAT Category E (0% - TAM)';
    }
}