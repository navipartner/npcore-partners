codeunit 6151610 "NPR BG Audit Mgt."
{
    Access = Internal;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region BG Fiscal - POS Handling Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsBGAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddBGAuditHandler(tmpRetailList);
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

    #region BG Fiscal - Audit Profile Mgt
    local procedure AddBGAuditHandler(var tmpRetailList: Record "NPR Retail List")
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
        BGPOSAuditLogAuxInfo: Record "NPR BG POS Audit Log Aux. Info";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsBGAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not BGPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertBGPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertBGPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        BGPOSAuditLogAuxInfo: Record "NPR BG POS Audit Log Aux. Info";
    begin
        BGPOSAuditLogAuxInfo.Init();
        BGPOSAuditLogAuxInfo."Audit Entry Type" := BGPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        BGPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        BGPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        BGPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        BGPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        BGPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        BGPOSAuditLogAuxInfo.Insert();
    end;

    #endregion

    #region BG Fiscal - Procedures/Helper Functions
    internal procedure IsBGFiscalActive(): Boolean
    var
        BGFiscalSetup: Record "NPR BG Fiscalization Setup";
    begin
        if BGFiscalSetup.Get() then
            exit(BGFiscalSetup."Enable BG Fiscal");
    end;

    local procedure IsBGAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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
        HandlerCodeTxt: Label 'BG_FISCAL', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        BGFiscalisationSetup: Page "NPR BG Fiscalization Setup";
    begin
        BGFiscalisationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        BGPOSAuditLogAuxInfo: Record "NPR BG POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - BG POS Audit Log Aux. Info table caption';
    begin
        BGPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not BGPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, BGPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        BGPOSAuditLogAuxInfo: Record "NPR BG POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - BG POS Audit Log Aux. Info table caption';
    begin
        if not IsBGAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        BGPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not BGPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", BGPOSAuditLogAuxInfo.TableCaption());
    end;

    #endregion
}