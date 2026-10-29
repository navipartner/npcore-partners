enum 6059800 "NPR CMPaymentOption"
{
    Extensible = false;
    Access = Internal;
    Caption = 'OTA Channel Manager Payment Option';

    value(0; Prepaid)
    {
        Caption = 'Prepaid';
    }

    value(1; PayAtPickup)
    {
        Caption = 'Pay at Pick-up';
    }

    value(2; Invoice)
    {
        Caption = 'Invoice';
    }
}
