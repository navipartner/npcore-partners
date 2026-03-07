codeunit 6248727 "NPR RO Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddROAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ROFiscalisationSetup: Record "NPR RO Fiscalisation Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        ROFiscalisationSetup.ChangeCompany(CompanyName);
        if ROFiscalisationSetup.Get() then
            ROFiscalisationSetup.Delete();
    end;
#endif

    local procedure AddROAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not Initialized then begin
            if not POSAuditProfile.Get(POSAuditProfileCode) then
                exit(false);

            if POSAuditProfile."Audit Handler" <> HandlerCode() then
                exit(false);

            Initialized := true;
            Enabled := true;
        end;

        exit(Enabled);
    end;

    local procedure HandleOnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;

        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;
    end;

    internal procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'RO_FISCAL', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;
}