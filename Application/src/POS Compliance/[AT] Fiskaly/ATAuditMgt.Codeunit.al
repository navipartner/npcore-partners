codeunit 6184848 "NPR AT Audit Mgt."
{
    Access = Internal;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region AT Fiscal - POS Handling Subscribers
    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsATAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddATAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;
    #endregion

    #region AT Fiscal - Audit Profile Mgt
    local procedure AddATAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    local procedure HandleOnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;

        if not IsATAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        // TO-DO InsertATAuditLogAuxInfo
    end;
    #endregion

    #region Subscribers - POS Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure HandleOnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsATAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        // TO-DO TestIsProfileSetAccordingToCompliance;
    end;
    #endregion

    #region AT Fiscal - Procedures/Helper Functions
    local procedure IsATAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);

        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);

        if Initialized then
            exit(Enabled);

        Initialized := true;
        Enabled := true;
        exit(true);
    end;

    local procedure HandlerCode(): Code[20]
    var
        HandlerCodeTxt: Label 'AT_FISKALY', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        ATFiscalizationSetup: Page "NPR AT Fiscalization Setup";
    begin
        ATFiscalizationSetup.RunModal();
    end;
    #endregion

    #region Procedures - Validations
    #endregion

    #region Procedures - Misc
    #endregion
}