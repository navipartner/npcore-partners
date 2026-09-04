codeunit 6248407 "NPR PL Digmatix Audit Mgt."
{
    Access = Internal;

    #region PL Fiscal - POS Handling Subscribers
    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsPLAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddPLAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        PLFiscalizationSetup: Record "NPR PL Digmatix Fisc. Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        PLFiscalizationSetup.ChangeCompany(CompanyName);
        if PLFiscalizationSetup.Get() then
            PLFiscalizationSetup.Delete();
    end;
    #endregion

    #region PL Fiscal - Audit Profile Mgt
    local procedure AddPLAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;
    #endregion

    #region PL Fiscal - POS Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure HandleOnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        PLFiscalIntegration: Codeunit "NPR PL Digmatix Fiscal Int.";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if not PLFiscalIntegration.IsPLFiscalActive() then
            exit;

        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsPLAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        PLFiscalIntegration.OnTestIsProfileSetAccordingToComplianceOnBeforeInitSale(POSUnit);
    end;
    #endregion

    #region PL Fiscal - Helper Procedures
    internal procedure IsPLAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);

        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);

        exit(true);
    end;

    procedure HandlerCode(): Code[20]
    var
        HandlerCodeTxt: Label 'PL_DIGMATIX', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        PLFiscalizationSetup: Page "NPR PL Digmatix Fisc. Setup";
    begin
        PLFiscalizationSetup.RunModal();
    end;
    #endregion
}