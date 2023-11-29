codeunit 6184647 "NPR IT Audit Mgt."
{
    Access = Internal;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region IT Fiscal - POS Handling Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsITAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddITAuditHandler(tmpRetailList);
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

    #region IT Fiscal - Audit Profile Mgt
    local procedure AddITAuditHandler(var tmpRetailList: Record "NPR Retail List")
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
        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertITPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertITPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
    begin
        ITPOSAuditLogAuxInfo.Init();
        ITPOSAuditLogAuxInfo."Audit Entry Type" := ITPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        ITPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        ITPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        ITPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        ITPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        ITPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        ITPOSAuditLogAuxInfo.Insert();
    end;

    #endregion

    #region IT Fiscal - Procedures/Helper Functions
    internal procedure IsITFiscalActive(): Boolean
    var
        ITFiscalSetup: Record "NPR IT Fiscalization Setup";
    begin
        if ITFiscalSetup.Get() then
            exit(ITFiscalSetup."Enable IT Fiscal");
    end;

    local procedure IsITAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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
        HandlerCodeTxt: Label 'IT_ENTRATE', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        ITFiscalisationSetup: Page "NPR IT Fiscalization Setup";
    begin
        ITFiscalisationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - IT POS Audit Log Aux. Info table caption';
    begin
        ITPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not ITPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, ITPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - IT POS Audit Log Aux. Info table caption';
    begin
        if not IsITAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        ITPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not ITPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", ITPOSAuditLogAuxInfo.TableCaption());
    end;

    #endregion
}