codeunit 6151485 "NPR CRO Audit Mgt."
{
    Access = Internal;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region CRO Fiscal - POS Handling Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsCROAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddCROAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSStore(var Rec: Record "NPR POS Store"; var xRec: Record "NPR POS Store"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSStoreIfAlreadyUsed(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSUnit(var Rec: Record "NPR POS Unit"; var xRec: Record "NPR POS Unit"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSUnitIfAlreadyUsed(xRec);
    end;

    #endregion

    #region CRO Fiscal - Audit Profile Mgt
    local procedure AddCROAuditHandler(var tmpRetailList: Record "NPR Retail List")
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
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsCROAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not CROPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertCROPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertCROPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
    begin
        CROPOSAuditLogAuxInfo.Init();
        CROPOSAuditLogAuxInfo."Audit Entry Type" := CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        CROPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        CROPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        CROPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        CROPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        CROPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        CROPOSAuditLogAuxInfo.Insert();
    end;

    #endregion

    #region CRO Fiscal - Procedures/Helper Functions
    internal procedure IsCROFiscalActive(): Boolean
    var
        CROFiscalSetup: Record "NPR CRO Fiscalization Setup";
    begin
        if CROFiscalSetup.Get() then
            exit(CROFiscalSetup."Enable CRO Fiscal");
    end;

    local procedure IsCROAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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

    local procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'CRO_FINA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        CROFiscalisationSetup: Page "NPR CRO Fiscalization Setup";
    begin
        CROFiscalisationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - CRO POS Audit Log Aux. Info table caption';
    begin
        CROPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not CROPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, CROPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - CRO POS Audit Log Aux. Info table caption';
    begin
        if not IsCROAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        CROPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not CROPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", CROPOSAuditLogAuxInfo.TableCaption());
    end;

    #endregion
}