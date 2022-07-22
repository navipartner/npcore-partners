enum 6014506 "NPR ShipProviderDocumentType"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF

    Caption = 'Shipping Provider Document Type';
    value(0; "Order")
    {
        Caption = 'Order';
    }
    value(5; Shipment)
    {
        Caption = 'Shipment';
    }
}
