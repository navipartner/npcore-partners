codeunit 6248243 "NPR Compliance Fiscal Mgt."
{
    Access = Internal;

    #region POS Store Location Code Lookup
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnBeforeNormalLookupLocationCode', '', false, false)]
    local procedure OnBeforeNormalLookupLocationCode(var POSStore: Record "NPR POS Store"; var IsHandled: Boolean)
    begin
        IsHandled := POSStoreLocationCodeRetailDrillDown(POSStore);
    end;

    local procedure POSStoreLocationCodeRetailDrillDown(var POSStore: Record "NPR POS Store"): Boolean
    var
        Location: Record Location;
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        LocationList: Page "Location List";
    begin
        if (not RSAuditMgt.IsRSFiscalActive()) or (not RSRLocalizationMgt.IsRSLocalizationActive()) then
            exit(false);
        LocationList.LookupMode := true;
        Location.FilterGroup(2);
        Location.SetRange("NPR Retail Location", true);
        Location.FilterGroup(0);
        LocationList.SetTableView(Location);
        if not (LocationList.RunModal() = Action::LookupOK) then
            exit(true);
        LocationList.GetRecord(Location);
        POSStore.Validate("Location Code", Location.Code);
        exit(true);
    end;
    #endregion POS Store Location Code Lookup

    #region Sales Line Location Checks

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure SalesLine_OnAfterValidate_LocationCode(var xRec: Record "Sales Line"; var Rec: Record "Sales Line")
    begin
        CheckForDifferentLocationTypes(xRec, Rec);
    end;

    internal procedure CheckForDifferentLocationTypes(xSalesLine: Record "Sales Line"; SalesLine: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        RetailLocation: Boolean;
        AllLocationsOnDocumentMustBeSameType: Label 'All locations chosen on sales lines must be of the same type.';
    begin
        if (not RSRLocalizationMgt.IsRSLocalizationActive()) or (not RSAuditMgt.IsRSFiscalActive()) or (not RSEInvoiceMgt.IsRSEInvoiceEnabled()) then
            exit;
        if (SalesLine."Location Code" = '') or (not (SalesLine.Type = SalesLine.Type::Item)) or (xSalesLine."Location Code" = SalesLine."Location Code") then
            exit;
        if CheckSalesLineItemCountOne(SalesLine."Document No.") then
            exit;
        if not CheckSalesLinesLocationsEmpty(SalesLine."Document No.") then
            exit;
        if not GetFirstSalesLineWithLocation(SalesLine2, SalesLine) then
            exit;

        RetailLocation := RSRLocalizationMgt.IsRetailLocation(SalesLine2."Location Code");

        if RetailLocation and (not RSRLocalizationMgt.IsRetailLocation(SalesLine."Location Code")) then
            Error(AllLocationsOnDocumentMustBeSameType);

        if (not RetailLocation) and RSRLocalizationMgt.IsRetailLocation(SalesLine."Location Code") then
            Error(AllLocationsOnDocumentMustBeSameType);
    end;

    local procedure GetFirstSalesLineWithLocation(var SalesLine2: Record "Sales Line"; SalesLine: Record "Sales Line"): Boolean
    begin
        SalesLine2.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine2.SetLoadFields("Location Code");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetRange(Type, SalesLine2.Type::Item);
        SalesLine2.SetFilter("Line No.", '<>%1', SalesLine."Line No.");
        SalesLine2.SetFilter("Location Code", '<>%1', '');
        exit(SalesLine2.FindFirst());
    end;

    local procedure CheckSalesLineItemCountOne(DocumentNo: Code[20]): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        exit(SalesLine.Count() = 1);
    end;

    local procedure CheckSalesLinesLocationsEmpty(DocumentNo: Code[20]): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Location Code", '<>%1', '');
        exit(not SalesLine.IsEmpty());
    end;
    #endregion Sales Line Location Checks

    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
}