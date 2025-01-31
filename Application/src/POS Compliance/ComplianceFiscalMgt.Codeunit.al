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

    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
}