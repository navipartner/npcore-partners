enum 6014688 "NPR DK SAF-T Payment Type"
{
    Access = Internal;
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Cash)
    {
        Caption = 'Cash';
    }
    value(2; "Debit Card")
    {
        Caption = 'Debit Card (Dankort)';
    }
    value(3; "Credit Card")
    {
        Caption = 'Credit Card';
    }
    value(4; "Bank Account")
    {
        Caption = 'Bank Account';
    }
    value(5; "Gift Token")
    {
        Caption = 'Gift Token';
    }
    value(6; "Customer Card")
    {
        Caption = 'Customer Card';
    }
    value(7; Loyalty)
    {
        Caption = 'Loyalty and Stamps';
    }
    value(8; "Bottle Deposit")
    {
        Caption = 'Bottle Deposit';
    }
    value(9; Check)
    {
        Caption = 'Check';
    }
    value(10; "Credit Note")
    {
        Caption = 'Credit Note';
    }
    value(11; "Mobile Phone App")
    {
        Caption = 'Mobile Phone App (MobilePay)';
    }
    value(12; Other)
    {
        Caption = 'Other';
    }
}
