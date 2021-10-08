codeunit 6014624 "NPR Shipmondo Try Create Shpt."
{
    TableNo = "Sales Shipment Header";

    trigger OnRun()
    var
        RecRef: RecordRef;
        ShipmondoMgt: Codeunit "NPR Shipmondo Mgnt.";
    begin
        RecRef.GetTable(Rec);
        ShipmondoMgt.AddEntry(RecRef, GuiAllowed, false);
    end;
}