enum 6014699 "NPR CMOrderLinePickupState"
{
    Extensible = false;
    Access = Internal;
    Caption = 'OTA Channel Manager Order Line Pick-up State';

    value(0; Open)
    {
        Caption = ' ';
    }

    value(1; InPosSale)
    {
        Caption = 'In POS Sale';
    }

    value(2; Paid)
    {
        Caption = 'Paid';
    }

    value(3; ParkedSale)
    {
        Caption = 'Parked Sale';
    }
}
