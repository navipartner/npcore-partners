interface "NPR IShipping Provider Interface"
{
    procedure CheckBalance()
    Procedure SendDocument(var ShipmentDocument: Record "NPR shipping provider Document");
    procedure PrintDocument(var ShipmentDocument: Record "NPR shipping provider Document")
    procedure PrintShipmentDocument(var SalesShipmentHeader: Record "Sales Shipment Header")

}