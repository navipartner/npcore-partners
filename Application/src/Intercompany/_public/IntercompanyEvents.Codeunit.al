codeunit 6151066 "NPR Intercompany Events"
{
    [IntegrationEvent(false, false)]
    internal procedure OnMapItemRecerenceToPurchaseLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]; var Identified: Boolean)
    begin
    end;
}