codeunit 6184795 "NPR Shipmondo Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure AddEntryOnBeforeShipmentDocumentModify(var ShipmentDocument: Record "NPR Shipping Provider Document"; RecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEndShipmentBuild(var PakkelabelsShipment: Record "NPR Shipping Provider Document"; var Output: Text)
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterShipmentBuild(var PakkelabelsShipment: Record "NPR Shipping Provider Document"; var Output: Text)
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPopulatePackageAmountFields(SalesHeader: Record "Sales Header"; var PackageDimension: Record "NPR Package Dimension"; var FieldsPopulated: Boolean)
    begin
    end;
}