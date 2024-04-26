codeunit 6184775 "NPR HU EInvoice Local. Mgt."
{
    Access = Internal;

    var
        HasHUEInvoiceLocalisationSetup: Boolean;

    internal procedure GetLocalisationSetupEnabled(): Boolean
    var
        HUEInvoiceLocalisationSetup: Record "NPR HU EInvoice Local. Setup";
    begin
        if not HasHUEInvoiceLocalisationSetup then
            if not HUEInvoiceLocalisationSetup.Get() then
                exit(false);

        exit(HUEInvoiceLocalisationSetup."Enable HU EInvoice Local");
    end;

    internal procedure SalesHeaderOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        SalesHeader.Modify(true);
        SaleLinePOS.SetLoadFields("Imported from Invoice No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Imported from Invoice No.", '<>%1', '');

        if SaleLinePOS.FindFirst() then begin
            RecRef.Open(Database::"Sales Header");
            RecRef.Get(SalesHeader.RecordId);
            if not RecRef.FieldExist(42014082) then
                exit;
            FieldReference := RecRef.Field(42014082);
            FieldReference.Value(SaleLinePOS."Imported from Invoice No.");
            RecRef.Modify();
            RecRef.Close();
            SalesHeader.Find();
        end;
    end;
}